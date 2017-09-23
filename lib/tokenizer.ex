defmodule JackAnalyzer.Tokenizer do
  @moduledoc """
  Used for converting Jack source code into it's tokenized form.
  """

  require JackAnalyzer.Tokenizer.Guards

  @type token_type :: :keyword
                    | :symbol
                    | :integerConstant
                    | :stringConstant
                    | :identifer

  @type token_value :: binary()
  @type token :: {token_type, token_value}
  @type tokens :: {:tokens, [token]}

  @typep line_num :: integer
  @typep col_num :: integer

  @keywords ~w(
    class
    constructor
    function
    method
    field
    static
    var
    int
    char
    boolean
    void
    true
    false
    null
    this
    let
    do
    if
    else
    while
    return
  ) |> Enum.map(&to_charlist/1)

  @doc """
  Given a Jack source file, returns its tokens
  """
  @spec tokenize(binary) :: tokens
  @spec tokenize(charlist, line_num, col_num, [token]) :: [token]
  def tokenize(input) do
    tokens =
      input
      |> String.trim
      |> to_charlist
      |> tokenize(1, 0, [])

    {:tokens, tokens}
  end

  # Finished parsing source file
  def tokenize([], _, _, tks), do: tks

  # Whitespace encountered
  def tokenize([x | rest], line, col, tks) when is_whitespace(x) do
    case x do
      x when x in [?\n, ?\r] -> tokenize(rest, line + 1, 0, tks)
      x when x in [32, ?\t] -> tokenize(rest, line, col + 1, tks)
    end
  end

  # Comment encountered
  def tokenize([a, b | rest], line, col, tks) when is_comment_start(a, b) do
    case b do
      ?/ -> handle_line_comment(rest, line, col + 2, tks)
      ?* -> handle_block_comment(rest, line, col + 2, tks)
    end
  end

  # Symbol encountered
  def tokenize([sym | rest], line, col, tks) when is_symbol(sym),
    do: handle_symbol(sym, rest, line, col + 1, tks)

  # String encountered
  def tokenize([?" | rest], line, col, tks),
    do: handle_string(rest, line, col + 1, tks)

  # Number encountered
  def tokenize(rest = [n | _], line, col, tks) when is_numeric(n),
    do: handle_number(rest, [], line, col, tks)

  # Possible keyword or identifier
  def tokenize(rest, line, col, tks),
    do: handle_token(rest, [], line, col + 1, tks)

  #--------------------------------------------------------------------------
  # Keywords or Identifiers
  #--------------------------------------------------------------------------

  # Finished handling
  defp handle_token(rest = [x | _], token, line, col, tks) when is_token_delim(x),
    do: keyword_or_identifier(rest, token, line, col, tks)

  # Continue handling
  defp handle_token([x | rest], token, line, col, tks),
    do: handle_token(rest, token ++ [x], line, col + 1, tks)

  # Determines if a token is a keyword or an identifier
  defp keyword_or_identifier(rest, token, line, col, tks) do
    cond do
      token in @keywords ->
        tokenize(rest, line, col, add_token({:keyword, to_string(token)}, tks))
      valid_identifier(token) ->
        tokenize(rest, line, col, add_token({:identifier, to_string(token)}, tks))
      :default ->
        throw_error("Invalid token '#{token}'", line, col, tks)
    end
  end

  # Determines if a token is a valid identifier
  defp valid_identifier([x | rest]) when is_identifier_start(x),
    do: Enum.all?(rest, fn x -> is_identifier_char(x) end)
  defp valid_identifier(_), do: false

  #--------------------------------------------------------------------------
  # Numbers
  #--------------------------------------------------------------------------

  # Continue handling number
  defp handle_number([n | rest], num, line, col, tks) when is_numeric(n),
    do: handle_number(rest, num ++ [n], line, col + 1, tks)

  # Finished handling number
  defp handle_number(rest = [n | _], num, line, col, tks) when is_token_delim(n),
    do: tokenize(rest, line, col, add_token({:integerConstant, to_string(num)}, tks))

  # Error: invalid token
  defp handle_number(_, num, line, col, tks) do
    msg = "Non-integer encountered when parsing integer, after: '#{num}'"
    throw_error(msg, line, col, tks)
  end

  #--------------------------------------------------------------------------
  # Symbols
  #--------------------------------------------------------------------------

  # Handle parsing symbol
  defp handle_symbol(sym, rest, line, col, tks),
    do: tokenize(rest, line, col, add_token({:symbol, <<sym :: utf8>>}, tks))

  #--------------------------------------------------------------------------
  # Line Comments
  #--------------------------------------------------------------------------

  # Finished handling line comment
  defp handle_line_comment([x | rest], line, _, tks) when is_newline(x),
    do: tokenize(rest, line + 1, 0, tks)

  # Continue handling line comment
  defp handle_line_comment([_ | rest], line, col, tks),
    do: handle_line_comment(rest, line, col + 1, tks)

  #--------------------------------------------------------------------------
  # Block Comments
  #--------------------------------------------------------------------------

  # Newline encountered
  defp handle_block_comment([x | rest], line, _, tks) when is_newline(x),
    do: handle_block_comment(rest, line + 1, 0, tks)

  # Finished handling block comment
  defp handle_block_comment([a, b | rest], line, col, tks) when is_comment_end(a, b),
    do: tokenize(rest, line, col, tks)

  # Continue handling block comment
  defp handle_block_comment([_ | rest], line, col, tks),
    do: handle_block_comment(rest, line, col + 1, tks)

  #--------------------------------------------------------------------------
  # Strings
  #--------------------------------------------------------------------------

  # Begin handling string
  defp handle_string(rest, line, col, tks),
    do: handle_string(rest, [], line, col, tks)

  # Newline encountered
  defp handle_string([x | _], charlist, line, col, tks) when is_newline(x) do
    msg = "Newline encountered in string literal after: \"#{charlist}\""
    throw_error(msg, line, col, tks)
  end

  # finished handling string
  defp handle_string([?" | rest], charlist, line, col, tks) do
    tks = add_token({:stringConstant, to_string(charlist)}, tks)
    tokenize(rest, line, col + 1, tks)
  end

  # Continue handling string
  defp handle_string([next | rest], charlist, line, col, tks),
    do: handle_string(rest, charlist ++ [next], line, col + 1, tks)

  #--------------------------------------------------------------------------
  # Utility
  #--------------------------------------------------------------------------

  # Adds a token to the token list
  defp add_token({type, value}, tks), do: tks ++ [{type, value}]

  # Throws and
  defp throw_error(msg, line, col, tks, extra \\ []) do
    print_err("\nTokenizer Error\nLine #{line}, Column #{col}\n#{msg}\n")
    print_line()
    if extra != [], do: print_err(extra, :inspect)
    for tk <- tks, do: print_err(tk, :inspect)
    print_line()
    System.halt(0)
  end

  defp print_err(str), do: print_err(str, :print)
  defp print_err(str, :print), do: IO.puts(:stderr, str)
  defp print_err(str, :inspect), do: IO.inspect(:stderr, str, [])
  defp print_line, do: print_err("-------------------------------------------------")
end

defmodule JackAnalyzer.Tokenizer.Guards do
  @moduledoc """
  Guards macros used for tokenization
  """

  @symbols '{}()[].,;+-*/&|<>=~'
  @numeric '01234567890'
  @upper for n <- ?a..?z, do: n
  @lower for n <- ?A..?Z, do: n

  @doc """
  Checks if the two chars form a comment start.

  Block comments start with `/*` and line comments start with `//`.
  """
  defmacro is_comment_start(a, b) do
    quote do
      (unquote(a) == ?/ and unquote(b) == ?/) or
      (unquote(a) == ?/ and unquote(b) == ?*)
    end
  end

  @doc """
  Check if the two chars form the end of a block comment (`*/`).
  """
  defmacro is_comment_end(a, b) do
    quote do
      unquote(a) == ?* and unquote(b) == ?/
    end
  end

  @doc """
  Checks if the char is a valid as the start of an identifier.

  Identifiers can start with any ascii uppercase, any ascii lowercase, or an
  underscore.
  """
  defmacro is_identifier_start(x) do
    quote do
      unquote(x) in unquote(@upper)
      or unquote(x) in unquote(@lower)
      or unquote(x) == ?_
    end
  end

  @doc """
  Checks if the char is a valid inside of an identifier.

  Identifiers can contain any ascii uppercase, any ascii lowercase, any
  numeric, or an underscore.
  """
  defmacro is_identifier_char(x) do
    quote do
      unquote(x) in unquote(@upper)
      or unquote(x) in unquote(@lower)
      or unquote(x) in unquote(@numeric)
      or unquote(x) == ?_
    end
  end

  @doc """
  Checks if the char is a valid numeric (`0-9`).
  """
  defmacro is_numeric(n) do
    quote do
      unquote(n) in unquote(@numeric)
    end
  end

  @doc """
  Checks if the char is a valid symbol (`{}()[].,;+-*/&|<>=~`).
  """
  defmacro is_symbol(x) do
    quote do
      unquote(x) in unquote(@symbols)
    end
  end

  @doc """
  Checks if the char is a newline (`\n` or `\r`).
  """
  defmacro is_newline(x) do
    quote do
      unquote(x) == ?\n
      or unquote(x) == ?\r
    end
  end

  @doc """
  Checks if the char is whitespace (`\n`, `\r`, space, or tab).
  """
  defmacro is_whitespace(x) do
    quote do
      unquote(x) == ?\n
      or unquote(x) == ?\r
      or unquote(x) == 32
      or unquote(x) == ?\t
    end
  end

  @doc """
  Checks if the char is valid token delimeter (any symbol, space, or newline).
  """
  defmacro is_token_delim(x) do
    quote do
      unquote(x) in unquote(@symbols)
      or unquote(x) == ?\n
      or unquote(x) == 32 #space
    end
  end
end

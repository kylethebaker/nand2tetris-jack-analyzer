defmodule JackAnalyzer do
  @moduledoc """
  Compiles Jack source code into Jack VM code.
  """

  alias JackAnalyzer.{Tokenizer, Compiler, PrettyPrinter}

  @type compiled_result :: {target_type, {Tokenizer.tokens, Compiler.tree_node}}
  @type compile_options :: [save_xml: boolean,
                            output_tokens: boolean,
                            print_results: boolean]

  @type path :: binary
  @type target :: path | binary
  @type target_type :: path | :string

  @default_compile_opts [
    save_xml: true,
    output_tokens: false,
    print_results: false
  ]

  @doc """
  Compiles jack source from the provided `target` and outputs the results.

  ## Options

    * `:save_xml` - When true, saves the parse tree as xml into the source dir.
    * `:output_tokens` - When true, the tokens will be included in the output.
    * `:print_results` - When true, prints the results to the screen.

  """
  @spec compile(target, compile_options) :: :ok
  def compile(target, opts \\ []) do
    opts = Keyword.merge(@default_compile_opts, opts)

    results = compile_target(target)

    if opts[:save_xml] do
      save_all_results(results, opts[:output_tokens])
    end

    if opts[:print_results] do
      print_all_results(results, opts[:output_tokens])
    end

    :ok
  end

  @doc """
  Compiles jack source from the provided `target`.

  Accepts either a directory, a single .jack file, or a string of code. If a
  directory is provided all .jack files from the directory will be compiled.

  Returns a list of compiled targets.
  """
  @spec compile_target(binary) :: [compiled_result]
  def compile_target(target) when is_binary(target) do
    results =
      cond do
        File.dir?(target) ->
          target |> Path.expand |> compile_directory
        File.exists?(target) and Path.extname(target) === ".jack"  ->
          compile_file(target)
        :default ->
          compile_string(target)
      end

    List.wrap(results)
  end

  @doc """
  Compiles a string of Jack source code
  """
  @spec compile_string(binary) :: compiled_result
  def compile_string(str) do
    tokens = Tokenizer.tokenize(str)
    tree = Compiler.compile(tokens)
    {:string, {tokens, tree}}
  end

  @doc """
  Compiles a Jack source code file
  """
  @spec compile_file(path) :: compiled_result
  def compile_file(file) do
    {_, results} = file |> File.read! |> compile_string
    {file, results}
  end

  @doc """
  Compiles all Jack source code files in a directory
  """
  @spec compile_directory(path) :: [compiled_result]
  def compile_directory(dir) do
    dir
    |> File.ls!
    |> Enum.filter(&(Path.extname(&1) == ".jack"))
    |> Enum.map(&compile_file(dir <> "/" <> &1))
  end

  @doc """
  Checks if the target is a valid compilation target. Valid targets are either
  files with .jack extensions, or a directory containing at least one .jack
  file.
  """
  @spec validate_target(any) :: :ok | {:error, binary}
  def validate_target(target) when is_binary(target) do
    cond do
      File.exists?(target) and Path.extname(target) === ".jack"  ->
        :ok
      File.dir?(target) ->
        if dir_contains_jack_file?(target) do
          :ok
        else
          {:error, "Directory doesn't contain any .jack files."}
        end
      :default ->
        {:error, "Not a file or directory."}
    end
  end
  def validate_target(_), do: false

  # Checks if a directory contains at least one .jack file
  defp dir_contains_jack_file?(dir) do
    dir
    |> File.ls!
    |> Enum.filter(&(Path.extname(&1) === ".jack"))
    |> length
    |> (&(&1 > 0)).()
  end

  # Generates output filenames
  defp output_file_name(source_file, type),
    do: Path.rootname(source_file) <> output_file_suffix(type)

  # Returns the appropriate filename suffix used for saving filesk
  defp output_file_suffix(:tokens), do: "_Tokens.xml"
  defp output_file_suffix(:tree), do: "_Tree.xml"

  # Writes compilation data to file as xml
  defp to_xml_file(data, source_file, type) do
    out_file = output_file_name(source_file, type)
    xml = convert_to_xml(data)
    File.write!(out_file, xml)
    out_file
  end

  # Converts tokens or tree data into an xml string
  defp convert_to_xml(data),
    do: data |> prepare_xml |> XmlBuilder.generate

  # Converts tokens or tree data into a structure excepted by the XmlBuilder
  defp prepare_xml({key, value}) when is_list(value),
    do: {key, nil, Enum.map(value, &prepare_xml/1)}
  defp prepare_xml({key, value}),
    do: {key, nil, value}

  # Saves all of the compiled results to xml files
  defp save_all_results(results, save_tokens?) do
    for {source, {tokens, tree}} <- results, source !== :string do
      out_file = to_xml_file(tree, source, :tree)
      IO.puts "Wrote parsed tree to #{out_file}"
      if save_tokens? do
        out_file = to_xml_file(tokens, source, :tokens)
        IO.puts "Wrote tokens to #{out_file}"
      end
    end
  end

  # Prints all of the compiled results to stdout
  defp print_all_results(results, show_tokens?) do
    for {source, {tokens, tree}} <- results do
      source_print =if source === :string, do: "string input", else: source
      IO.puts "Results for #{source_print}"
      IO.puts "Parse Tree:"
      PrettyPrinter.print(tree)
      IO.puts "\n"
      if show_tokens? do
        IO.puts "Tokens:"
        PrettyPrinter.print(tokens)
        IO.puts "\n"
      end
      IO.puts "-------------------------------------"
    end
  end
end

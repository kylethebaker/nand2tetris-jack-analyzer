defmodule JackAnalyzer.Cli do

  @switches [
    save_xml: :boolean,
    print_results: :boolean,
    output_tokens: :boolean,
  ]

  def main(args) do
    {target, opts} = parse_options(args)
    assert_valid_target(target)
    JackAnalyzer.compile(target, opts)
  end

  def parse_options(opts) do
    {opts, [target | _], _} = OptionParser.parse(opts, strict: @switches)
    {target, opts}
  end

  def assert_valid_target(target) do
    case JackAnalyzer.validate_target(target) do
      {:error, reason} ->
        IO.puts :stderr, "Invalid target '#{target}'. #{reason}"
        System.halt(0)
      :ok -> :ok
    end
  end

end

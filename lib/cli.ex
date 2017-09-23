defmodule JackAnalyzer.Cli do

  @switches [
    save_xml: :boolean,
    print_results: :boolean,
    output_tokens: :boolean,
  ]

  def main(args) do
    {target, opts} = parse_options
    JackAnalyzer.compile(target, opts)
  end

  def parse_options(opts) do
    {opts, [target | _], _} = OptionsParser.parse(opts, strict: @switches)
    {target, opts}
  end

end

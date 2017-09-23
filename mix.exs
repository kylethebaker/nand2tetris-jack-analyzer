defmodule JackAnalyzer.Mixfile do
  use Mix.Project

  def project, do: [
    app: :jack_analyzer,
    version: "0.1.0",
    elixir: "~> 1.5",
    start_permanent: Mix.env == :prod,
    escript: escript_config(),
    deps: deps()
  ]

  defp escript_config, do: [
    main_module: JackAnalyzer.Cli,
    name: "JackAnalyzer",
  ]

  def application, do: [
    extra_applications: [:logger]
  ]

  defp deps, do: [
    {:xml_builder, "~> 0.1.1"},
  ]
end

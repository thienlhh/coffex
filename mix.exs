defmodule Coffex.MixProject do
  use Mix.Project

  def project do
    [
      app: :coffex,
      escript: escript_config(),
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:scribe, "~> 0.8"},
      {:cli_spinners, "~> 0.1.0"},
      {:ex_football, "~> 0.1.0"}
    ]
  end

  defp escript_config do
    [
      main_module: Coffex.CLI
    ]
  end
end

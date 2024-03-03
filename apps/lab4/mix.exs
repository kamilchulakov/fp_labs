defmodule Lab4.MixProject do
  use Mix.Project

  def project do
    [
      app: :lab4,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
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
      {:plug_cowboy, "~> 2.0"},
      {:cubdb, "~> 2.0.2"},
      {:toml, "~> 0.7"},
      {:finch, "~> 0.18"},
      {:jason, "~> 1.4"}
    ]
  end

  defp escript do
    [
      main_module: Lab4.Application
    ]
  end
end

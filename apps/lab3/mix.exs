defmodule Lab3.MixProject do
  use Mix.Project

  def project do
    [
      app: :lab3,
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

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:gen_stage, "~> 1.0.0"}
    ]
  end

  defp escript do
    [
      main_module: Lab3.Application
    ]
  end
end

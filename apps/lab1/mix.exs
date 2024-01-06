defmodule Lab1.MixProject do
  use Mix.Project

  def project do
    [
      app: :lab1,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:elixir_math, "~> 0.1.0"},
      {:gradient, github: "esl/gradient", only: :dev, runtime: false},
      {:benchee, "~> 1.1", only: :dev},
      {:benchee_dsl, "~> 0.5", only: :dev},
      {:benchee_markdown, "~> 0.3.2", only: :dev}
    ]
  end
end

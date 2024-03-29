defmodule Lab2.MixProject do
  use Mix.Project

  def project do
    [
      app: :lab2,
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
      {:gradient, github: "esl/gradient", only: :dev, runtime: false},
      {:benchee, "~> 1.2.0", only: :dev},
      {:benchee_dsl, "~> 0.5", only: :dev},
      {:stream_data, "~> 0.6", only: :test}
    ]
  end
end

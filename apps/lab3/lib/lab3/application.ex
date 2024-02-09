defmodule Lab3.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def main(args) do
    start(:normal, args)
    :timer.sleep(:infinity)
  end

  @impl true
  def start(_type, args) do
    config = Lab3.Config.new(args)

    children = [
      {Lab3.Stage.Producer, []},
      {Lab3.Stage.ProducerConsumer, [step: config.step, window: config.window]},
      {Lab3.Stage.Consumer, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lab3.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

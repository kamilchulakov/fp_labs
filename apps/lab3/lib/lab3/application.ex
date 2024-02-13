defmodule Lab3.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
alias Lab3.Pipeline

  use Application

  def main(args) do
    start(:normal, args)
    :timer.sleep(:infinity)
  end

  @impl true
  def start(_type, args) do
    config = Lab3.Config.new(args)

    producer = {Lab3.Stage.Producer, []}
    producer_consumer = {Lab3.Stage.ProducerConsumer, [step: config.step, window: config.window]}
    consumer = {Lab3.Stage.Consumer, []}

    Pipeline.pipeline(producer: producer, processors: [producer_consumer, consumer])
  end
end

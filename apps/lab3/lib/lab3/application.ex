defmodule Lab3.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  alias Lab3.Stage.Pipeline

  use Application

  def main(args) do
    start(:normal, args)
    :timer.sleep(:infinity)
  end

  @impl true
  def start(_type, args) do
    config = Lab3.Config.new(args)

    producer = Supervisor.child_spec({Lab3.Stage.Producer, []}, id: :input)
    producer_consumer_1 = Supervisor.child_spec({Lab3.Stage.ProducerConsumer, [name: :pc1, step: config.step, window: config.window]}, id: :pc1)
    producer_consumer_2 = Supervisor.child_spec({Lab3.Stage.ProducerConsumer, [name: :pc2, step: config.step, window: config.window]}, id: :pc2)

    consumer = Supervisor.child_spec({Lab3.Stage.Consumer, []}, id: :printer)

    Pipeline.pipeline(producer: producer, processors: [producer_consumer_1, producer_consumer_2], consumer: consumer)
  end
end

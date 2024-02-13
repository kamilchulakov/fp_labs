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

    producer = Supervisor.child_spec({Lab3.Stage.Producer, name: :input}, id: :input)

    buffer = Supervisor.child_spec({Lab3.Stage.PointBuffer, name: :buffer}, id: :buffer)

    producer_consumer_1 = Supervisor.child_spec({Lab3.Stage.ProducerConsumer, name: :linear, algorithm: :linear, step: config.step, window: 2}, id: :linear)
    producer_consumer_2 = Supervisor.child_spec({Lab3.Stage.ProducerConsumer, name: :lagrange, algorithm: :lagrange, step: config.step, window: config.window}, id: :lagrange)

    consumer = Supervisor.child_spec({Lab3.Stage.Consumer, name: :printer}, id: :printer)

    Pipeline.pipeline(producer: producer, buffer: buffer, processors: [producer_consumer_1, producer_consumer_2], consumer: consumer)
  end
end

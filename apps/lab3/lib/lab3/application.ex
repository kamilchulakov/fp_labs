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

    producer = {Lab3.Stage.Producer, name: :input}
    buffer = {Lab3.Stage.PointBuffer, name: :buffer}

    processors = [
      {Lab3.Stage.ProducerConsumer, name: :linear, algorithm: :linear, step: config.step, window: 2},
      {Lab3.Stage.ProducerConsumer, name: :lagrange, algorithm: :lagrange, step: config.step, window: config.window}
    ]

    consumer = {Lab3.Stage.Consumer, name: :printer}

    Pipeline.pipeline(producer: producer, buffer: buffer, processors: processors, consumer: consumer)
  end
end

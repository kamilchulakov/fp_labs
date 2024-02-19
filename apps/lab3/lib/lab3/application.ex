defmodule Lab3.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  alias Lab3.Stage.Pipeline

  use Application

  def main(args) do
    {:ok, pid} = start(:normal, args)

    Process.link(pid)
    :timer.sleep(:infinity)
  end

  @impl true
  def start(_type, args) do
    config = Lab3.Config.new(args)

    producer = {Lab3.Stage.PointProducer, name: :input, separator: config.separator}
    buffer = {Lab3.Stage.PointBuffer, name: :buffer}

    processors = [
      {Lab3.Stage.PointProcessor,
       name: :linear, algorithm: :linear, step: config.step, window: 2},
      {Lab3.Stage.PointProcessor,
       name: :lagrange, algorithm: :lagrange, step: config.step, window: config.window},
      {Lab3.Stage.PointProcessor,
       name: :gauss, algorithm: :gauss, step: config.step, window: config.window}
    ]

    consumer = {Lab3.Stage.Printer, name: :printer}

    Pipeline.pipeline(
      producer: producer,
      buffer: buffer,
      processors: processors,
      consumer: consumer
    )
  end
end

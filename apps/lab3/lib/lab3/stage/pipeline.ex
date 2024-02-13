defmodule Lab3.Stage.Pipeline do
  def pipeline(producer: producer, buffer: buffer, processors: processors, consumer: consumer) do
    children = [producer, buffer, consumer | processors]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end

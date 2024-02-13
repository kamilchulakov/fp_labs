defmodule Lab3.Stage.Pipeline do
  def pipeline(producer: producer, processors: processors, consumer: consumer) do
    children = [producer, consumer | processors]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)
  end
end

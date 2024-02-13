defmodule Lab3.Pipeline do
  def pipeline(producer: producer, processors: processors) do
    children = [producer | processors]

    opts = [strategy: :one_for_one, name: Lab3.Pipeline]
    Supervisor.start_link(children, opts)
  end
end

defmodule Lab3.Stage.Pipeline do
  def pipeline(producer: producer, processors: processors, consumer: consumer) do
    children = [producer, consumer | processors]

    opts = [strategy: :one_for_one, name: __MODULE__]
    Supervisor.start_link(children, opts)

    processors
    |> Enum.each(&(GenStage.sync_subscribe(&1.id, to: producer.id, max_demand: 1)))

    processors
    |> Enum.each(&GenStage.sync_subscribe(consumer.id, to: &1.id))
  end
end

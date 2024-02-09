defmodule Lab3.Stage.ProducerConsumer do
  use GenStage

  alias Lab3.Interpolation.Linear

  require Integer

  def start_link(step) do
    GenStage.start_link(__MODULE__, step, name: __MODULE__)
  end

  def init(state) do
    {:producer_consumer, state, subscribe_to: [{Lab3.Stage.Producer, max_demand: 1}]}
  end

  def handle_events([points], _from, step) when length(points) == 2 do
    result = Linear.interpolate(points, step)

    {:noreply, [result], step}
  end
end

defmodule Lab3.Stage.ProducerConsumer do
  use GenStage

  require Integer

  def start_link(_initial) do
    GenStage.start_link(__MODULE__, :state_doesnt_matter, name: __MODULE__)
  end

  def init(state) do
    {:producer_consumer, state, subscribe_to: [{Lab3.Stage.Producer, max_demand: 1}]}
  end

  def handle_events(events, _from, state) do
    for event <- events do
      IO.puts("Handled: " <> event)
    end

    {:noreply, events, state}
  end
end

defmodule Lab3.Stage.Consumer do
  use GenStage

  def start_link(_initial) do
    GenStage.start_link(__MODULE__, :state_doesnt_matter)
  end

  def init(state) do
    {:consumer, state, subscribe_to: [Lab3.Stage.ProducerConsumer]}
  end

  def handle_events(events, _from, state) do
    IO.inspect(events)

    # As a consumer we never emit events
    {:noreply, [], state}
  end
end

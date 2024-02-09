defmodule Lab3.Stage.Consumer do
  @moduledoc """
  Stage for printing interpolation results.
  """

  use GenStage

  def start_link(_initial) do
    GenStage.start_link(__MODULE__, :state_doesnt_matter)
  end

  def init(state) do
    {:consumer, state, subscribe_to: [Lab3.Stage.ProducerConsumer]}
  end

  def handle_events([{method, points}], _from, state) do
    IO.puts("Method: #{method}")

    points
    |> Enum.map_join(", ", fn {x, y} -> "{#{x}, #{y}}" end)
    |> IO.puts()

    # As a consumer we never emit events
    {:noreply, [], state}
  end
end

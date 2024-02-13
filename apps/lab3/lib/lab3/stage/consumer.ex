defmodule Lab3.Stage.Consumer do
  @moduledoc """
  Stage for printing interpolation results.
  """

  use GenStage

  def start_link(_initial) do
    GenStage.start_link(__MODULE__, :state_doesnt_matter, name: :printer)
  end

  def init(state) do
    {:consumer, state}
  end

  def handle_events(events, _from, state) do
    events
    |> Enum.each(&handle_event/1)

    # As a consumer we never emit events
    {:noreply, [], state}
  end

  def handle_event({method, points}) do
    IO.puts("Method: #{method}")

    points
    |> Enum.map_join(", ", fn {x, y} -> "{#{x}, #{y}}" end)
    |> IO.puts()
  end
end

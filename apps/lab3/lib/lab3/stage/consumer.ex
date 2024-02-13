defmodule Lab3.Stage.Consumer do
  @moduledoc """
  Stage for printing interpolation results.
  """

  use GenServer

  def start_link(name: name) do
    GenServer.start_link(__MODULE__, :state_doesnt_matter, name: name)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_cast({method, points}, state) do
    IO.puts("Method: #{method}")

    points
    |> Enum.map_join(", ", fn {x, y} -> "{#{x}, #{y}}" end)
    |> IO.puts()

    {:noreply, state}
  end
end

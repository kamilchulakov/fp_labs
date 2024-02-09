defmodule Lab3.Stage.Producer do
  use GenStage

  def start_link(state) do
    GenStage.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(counter), do: {:producer, counter}

  def handle_demand(demand, state) when demand == 1 do
    point1 = read_point()
    point2 = read_point()

    {:noreply, [[point1, point2]], state}
  end

  defp read_point do
    IO.gets("")
    |> line_to_point
  end

  defp line_to_point(line) do
    line
    |> String.split(" ")
    |> Enum.map(&Float.parse/1)
    |> Enum.map(&elem(&1, 0))
    |> List.to_tuple()
  end
end

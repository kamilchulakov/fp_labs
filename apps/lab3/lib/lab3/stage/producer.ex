defmodule Lab3.Stage.Producer do
  @moduledoc """
  Stage for handling input and emitting events.
  """

  use GenStage

  def start_link(_state) do
    GenStage.start_link(__MODULE__, :state_doesnt_matter, name: __MODULE__)
  end

  def init(state), do: {:producer, state}

  # Produces 1 point at a time
  def handle_demand(demand, state) when demand == 1 do
    case read_point() do
      nil -> {:noreply, [], state}
      point -> {:noreply, [point], state}
    end
  end

  defp read_point do
    IO.gets("")
    |> line_to_point
  end

  defp line_to_point(:eof), do: nil

  defp line_to_point(line) do
    line
    |> String.split(" ")
    |> Enum.map(&Float.parse/1)
    |> Enum.map(&elem(&1, 0))
    |> List.to_tuple()
  end
end

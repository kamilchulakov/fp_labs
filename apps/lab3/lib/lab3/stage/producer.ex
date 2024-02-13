defmodule Lab3.Stage.Producer do
  @moduledoc """
  Stage for handling input and emitting events.
  """

  use GenServer

  def start_link(_state) do
    GenServer.start_link(__MODULE__, :state_doesnt_matter, name: :input)
  end

  def init(state) do
    {:ok, state, {:continue, :read_points}}
  end

  # Produces 1 point at a time
  def handle_continue(:read_points, state) do
    case read_point() do
      nil -> GenServer.stop(:input)
      point -> cast_point(point)
    end

    {:noreply, state, {:continue, :read_points}}
  end

  defp read_point do
    IO.gets(">")
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

  defp cast_point(point) do
    GenServer.cast(:buffer, {:add_point, point})
  end
end

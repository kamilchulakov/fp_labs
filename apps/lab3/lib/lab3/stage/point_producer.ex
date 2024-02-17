defmodule Lab3.Stage.PointProducer do
  @moduledoc """
  Stage for handling input and producing points.
  """

  use GenServer

  @enforce_keys [:buffer, :name]
  defstruct [:buffer, :name]

  defp new(buffer, name),
    do: %__MODULE__{buffer: buffer, name: name}

  def start_link(name: name, buffer: buffer) do
    GenServer.start_link(__MODULE__, new(buffer, name), name: name)
  end

  @impl true
  def init(state) do
    {:ok, state, {:continue, :read_points}}
  end

  # Produces 1 point at a time
  @impl true
  def handle_continue(:read_points, state) do
    case read_point() do
      nil -> GenServer.stop(state.name)
      point -> cast_point(point, state.buffer)
    end

    {:noreply, state, {:continue, :read_points}}
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

  defp cast_point(point, buffer) do
    GenServer.cast(buffer, {:add_point, point})
  end
end

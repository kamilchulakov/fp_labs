defmodule Lab3.Stage.PointProducer do
  @moduledoc """
  Stage for handling input and producing points.
  """

  use GenServer

  @enforce_keys [:buffer, :name, :separator]
  defstruct [:buffer, :name, :separator]

  defp new(buffer, name, separator),
    do: %__MODULE__{buffer: buffer, name: name, separator: separator}

  def start_link(name: name, separator: separator, buffer: buffer) do
    GenServer.start_link(__MODULE__, new(buffer, name, separator), name: name)
  end

  @impl true
  def init(state) do
    {:ok, state, {:continue, :read_points}}
  end

  # Produces 1 point at a time
  @impl true
  def handle_continue(:read_points, state) do
    case read_point(state.separator) do
      nil -> GenServer.stop(state.name)
      point -> cast_point(point, state.buffer)
    end

    {:noreply, state, {:continue, :read_points}}
  end

  defp read_point(separator) do
    IO.gets("")
    |> line_to_point(separator)
  end

  defp line_to_point(:eof, _), do: nil

  defp line_to_point(line, separator) do
    line
    |> String.split(separator)
    |> Enum.map(&Float.parse/1)
    |> Enum.map(&elem(&1, 0))
    |> List.to_tuple()
  end

  defp cast_point(point, buffer) do
    GenServer.cast(buffer, {:add_point, point})
  end
end

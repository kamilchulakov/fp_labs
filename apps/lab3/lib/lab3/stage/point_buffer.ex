defmodule Lab3.Stage.PointBuffer do
  @moduledoc """
  Stage for buffering points.
  """
  alias Lab3.Util.Window

  use GenServer

  @enforce_keys [:windows]
  defstruct [:windows]

  defp new(windows \\ %{}), do: %__MODULE__{windows: windows}

  def start_link(name: name) do
    GenServer.start_link(__MODULE__, new(), name: name)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:add_window, algorithm: algorithm, size: size}, %__MODULE__{windows: windows}) do
    {:noreply, Map.put(windows, algorithm, Window.new(size)) |> new()}
  end

  def handle_cast({:add_point, point}, %__MODULE__{windows: windows}) do
    state =
      windows
      |> add_point(point)
      |> cast_full()
      |> new()

    {:noreply, state}
  end

  defp add_point(windows, point) do
    windows
    |> Enum.map(fn {algorithm, window} -> {algorithm, Window.push(window, point)} end)
  end

  defp cast_full(windows) do
    windows
    |> Enum.filter(fn {_, window} -> Window.full?(window) end)
    |> Enum.each(fn {algorithm, window} ->
      GenServer.cast(algorithm, window.elements)
    end)

    windows
  end
end

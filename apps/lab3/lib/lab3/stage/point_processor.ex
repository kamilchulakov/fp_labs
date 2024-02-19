defmodule Lab3.Stage.PointProcessor do
  @moduledoc """
  Stage for handling events and emitting interpolation results.
  """

  use GenServer

  alias Lab3.Interpolation.Gauss
  alias Lab3.Interpolation.Lagrange
  alias Lab3.Interpolation.Linear
  alias Lab3.Stage.PointProcessor.State

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      State.new(opts),
      name: opts[:name]
    )
  end

  @impl true
  def init(state) do
    GenServer.cast(state.buffer, {:add_window, algorithm: state.algorithm, size: state.window})

    {:ok, state}
  end

  @impl true
  def handle_cast(points, state) when length(points) == state.window do
    result =
      handle_algorithm(state.algorithm, points, state.step)
      |> to_string(state.algorithm)

    GenServer.cast(state.consumer, result)

    {:noreply, state}
  end

  def handle_algorithm(:gauss, points, step), do: Gauss.interpolate(points, step)

  def handle_algorithm(:linear, points, step), do: Linear.interpolate(points, step)

  def handle_algorithm(:lagrange, points, step), do: Lagrange.interpolate(points, step)

  defp to_string(points, algorithm) do
    "Algorithm #{algorithm}:\n" <>
      (points |> Enum.map_join(", ", fn {x, y} -> "{#{x}, #{y}}" end))
  end
end

defmodule Lab3.Stage.PointProcessor.State do
  @moduledoc """
  Struct to store state.
  """

  @enforce_keys [:step, :window, :algorithm, :buffer, :consumer]
  defstruct [:step, :window, :algorithm, :buffer, :consumer]

  def new(opts),
    do: %__MODULE__{
      step: opts[:step],
      window: opts[:window],
      algorithm: opts[:algorithm],
      buffer: opts[:buffer],
      consumer: opts[:consumer]
    }
end

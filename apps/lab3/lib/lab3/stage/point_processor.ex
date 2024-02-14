defmodule Lab3.Stage.PointProcessor do
  @moduledoc """
  Stage for handling events and emitting interpolation results.
  """

  use GenServer

  alias Lab3.Interpolation.Lagrange
  alias Lab3.Interpolation.Linear
  alias Lab3.Stage.PointProcessor.State

  def start_link(opts) do
    GenServer.start_link(
      __MODULE__,
      State.new(opts[:step], opts[:window], opts[:algorithm], opts[:buffer], opts[:consumer]),
      name: opts[:name]
    )
  end

  def init(state) do
    GenServer.cast(state.buffer, {:add_window, algorithm: state.algorithm, size: state.window})

    {:ok, state}
  end

  def handle_cast(points, state) when length(points) == state.window do
    result = handle_algorithm(state.algorithm, points, state.step)

    GenServer.cast(state.consumer, {state.algorithm, result})

    {:noreply, state}
  end

  def handle_algorithm(:linear, points, step), do: Linear.interpolate(points, step)

  def handle_algorithm(:lagrange, points, step), do: Lagrange.interpolate(points, step)
end

defmodule Lab3.Stage.PointProcessor.State do
  @moduledoc """
  Struct to store state.
  """

  @enforce_keys [:step, :window, :algorithm, :buffer, :consumer]
  defstruct [:step, :window, :algorithm, :buffer, :consumer]

  def new(step, window, algorithm, buffer, consumer),
    do: %__MODULE__{
      step: step,
      window: window,
      algorithm: algorithm,
      buffer: buffer,
      consumer: consumer
    }
end

defmodule Lab3.Stage.ProducerConsumer do
  @moduledoc """
  Stage for handling events and emitting interpolation results.
  """

  use GenServer

  alias Lab3.Interpolation.Lagrange
  alias Lab3.Interpolation.Linear
  alias Lab3.Stage.ProducerConsumer.State

  def start_link(name: name, algorithm: algorithm, step: step, window: window) do
    GenServer.start_link(__MODULE__, State.new(step, window, algorithm), name: name)
  end

  def init(state) do
    GenServer.cast(:buffer, {:add_window, algorithm: state.algorithm, size: state.window})

    {:ok, state}
  end

  def handle_cast(points, state) when length(points) == state.window do
    result = handle_method(state.algorithm, points, state.step)

    GenServer.cast(:printer, {state.algorithm, result})

    {:noreply, state}
  end

  def handle_method(:linear, points, step), do: Linear.interpolate(points, step)

  def handle_method(:lagrange, points, step), do: Lagrange.interpolate(points, step)
end

defmodule Lab3.Stage.ProducerConsumer.State do
  @moduledoc """
  Struct to store state.
  """

  @enforce_keys [:step, :window, :algorithm]
  defstruct [:step, :window, :algorithm]

  def new(step, window, algorithm),
    do: %__MODULE__{
      step: step,
      window: window,
      algorithm: algorithm
    }
end

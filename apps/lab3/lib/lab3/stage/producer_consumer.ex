defmodule Lab3.Stage.ProducerConsumer do
  @moduledoc """
  Stage for handling events and emitting interpolation results.
  """

  use GenServer

  alias Lab3.Interpolation.Lagrange
  alias Lab3.Interpolation.Linear
  alias Lab3.Stage.ProducerConsumer.State

  def start_link(name: name, algorithm: algorithm, step: step, window: window, buffer: buffer, consumer: consumer) do
    GenServer.start_link(__MODULE__, State.new(step, window, algorithm, buffer, consumer), name: name)
  end

  def init(state) do
    GenServer.cast(state.buffer, {:add_window, algorithm: state.algorithm, size: state.window})

    {:ok, state}
  end

  def handle_cast(points, state) when length(points) == state.window do
    result = handle_method(state.algorithm, points, state.step)

    GenServer.cast(state.consumer, {state.algorithm, result})

    {:noreply, state}
  end

  def handle_method(:linear, points, step), do: Linear.interpolate(points, step)

  def handle_method(:lagrange, points, step), do: Lagrange.interpolate(points, step)
end

defmodule Lab3.Stage.ProducerConsumer.State do
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

defmodule Lab3.Stage.ProducerConsumer do
  @moduledoc """
  Stage for handling events and emitting interpolation results.
  """

  use GenStage

  alias Lab3.Interpolation.Lagrange
  alias Lab3.Interpolation.Linear
  alias Lab3.Stage.ProducerConsumer.State
  alias Lab3.Util.Window

  def start_link(step: step, window: window) do
    GenStage.start_link(__MODULE__, State.new(step, window), name: __MODULE__)
  end

  def init(state) do
    {:producer_consumer, state, subscribe_to: [{Lab3.Stage.Producer, max_demand: 1}]}
  end

  def handle_events([point], _from, state) do
    new_state = State.add_point(state, point)

    result =
      new_state.methods
      |> Enum.filter(fn {_, window} -> Window.full?(window) end)
      |> Enum.map(fn {method, window} ->
        {method, handle_method(method, window, new_state.step)}
      end)

    {:noreply, result, new_state}
  end

  def handle_method(:linear, window, step), do: Linear.interpolate(window.elements, step)

  def handle_method(:lagrange, window, step), do: Lagrange.interpolate(window.elements, step)
end

defmodule Lab3.Stage.ProducerConsumer.State do
  @moduledoc """
  Struct to store state.
  """

  alias Lab3.Util.Window

  @enforce_keys [:step, :methods]
  defstruct [:step, :methods]

  def new(step, window),
    do: %__MODULE__{
      step: step,
      methods: %{
        lagrange: Window.new(window),
        linear: Window.new(2)
      }
    }

  def add_point(
        %__MODULE__{
          step: step,
          methods: methods
        },
        point
      ),
      do: %__MODULE__{
        step: step,
        methods:
          Enum.map(methods, fn {method, window} -> {method, Window.push(window, point)} end)
      }
end

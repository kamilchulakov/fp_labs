defmodule Lab3.Stage.ProducerConsumer do
  use GenStage

  alias Lab3.Util.Window
  alias Lab3.Interpolation.Linear
  alias Lab3.Stage.ProducerConsumer.State

  require Integer

  def start_link(step) do
    GenStage.start_link(__MODULE__, State.new(step), name: __MODULE__)
  end

  def init(state) do
    {:producer_consumer, state, subscribe_to: [{Lab3.Stage.Producer, max_demand: 1}]}
  end

  def handle_events([point], _from, state) do
    new_state = State.add_point(state, point)

    if Window.full?(new_state.linear) do
      result = {:linear, Linear.interpolate(new_state.linear.elements, state.step)}
      {:noreply, [result], new_state}
    else
      {:noreply, [], new_state}
    end
  end
end

defmodule Lab3.Stage.ProducerConsumer.State do
  alias Lab3.Util.Window

  @enforce_keys [:step]
  defstruct [:step, linear: Window.new(2)]

  def new(step), do: %__MODULE__{step: step}

  def add_point(%__MODULE__{step: step, linear: linear_window}, point),
    do: %__MODULE__{step: step, linear: Window.push(linear_window, point)}
end

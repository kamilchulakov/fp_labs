defmodule Lab3.Stage.Producer do
  use GenStage

  def start_link(state) do
    GenStage.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(counter), do: {:producer, counter}

  def handle_demand(demand, state) when demand == 1 do
    data = IO.gets("input: ")

    {:noreply, [data], state}
  end
end

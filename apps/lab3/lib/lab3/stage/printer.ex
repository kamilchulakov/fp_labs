defmodule Lab3.Stage.Printer do
  @moduledoc """
  Stage for printing interpolation results.
  """

  use GenServer

  def start_link(name: name) do
    GenServer.start_link(__MODULE__, :state_doesnt_matter, name: name)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast(string, state) do
    IO.puts(string)

    {:noreply, state}
  end
end

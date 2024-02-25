defmodule Lab4.DB.Worker do
  use GenServer

  @enforce_keys [:db]
  defstruct [:db]

  def start_link(db: db) do
    GenServer.start_link(__MODULE__, db, name: __MODULE__)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:get, key}, _from, db) do
    {:reply, CubDB.get(db, key), db}
  end

  def handle_call({:set, key, value}, _from, db) do
    {:reply, CubDB.put(db, key, value), db}
  end
end

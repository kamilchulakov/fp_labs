defmodule Lab4.DB.Worker do
  use GenServer

  def start_link(db: db, name: name) do
    GenServer.start_link(__MODULE__, db, name: name)
  end

  @impl true
  def init(db) do
    {:ok, db}
  end

  @impl true
  def handle_call({:get, key}, _from, db) do
    {:reply, CubDB.get(db, key), db}
  end

  def handle_call({:set, key, value}, _from, db) do
    {:reply, CubDB.put(db, key, value), db}
  end
end

defmodule Lab4.DB.Worker do
  use GenServer

  def start_link(db: db, shard: shard, readonly: readonly, name: name) do
    GenServer.start_link(__MODULE__, %{db: db, shard: shard, readonly: readonly}, name: name)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:get, key}, _from, %{db: db} = state) do
    {:reply, CubDB.get(db, key), state}
  end

  def handle_call({:set, _key, _value}, _from, %{readonly: true} = state) do
    {:reply, :readonly, state}
  end

  def handle_call({:set, key, value}, _from, %{db: db} = state) do
    {:reply, CubDB.put(db, key, value), state}
  end

  def handle_call(:delete_extra, _from, state = %{db: db, shard: shard}) do
    extra_keys =
      CubDB.select(db)
      |> Stream.filter(fn {key, _value} -> !GenServer.call(shard, {:current, key}) end)
      |> Enum.to_list()

    {:reply, CubDB.delete_multi(db, extra_keys), state}
  end
end

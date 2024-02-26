defmodule Lab4.DB.Worker do
  @moduledoc """
  Module that works with storage: db and db_replica_bucket (for storing updates)
  """

  require Logger
  use GenServer

  def start_link(db: db, shard: shard, readonly: readonly, name: name) do
    GenServer.start_link(__MODULE__, %{db: db, shard: shard, readonly: readonly, name: name}, name: name)
  end

  def start_link(
        db: db,
        db_replica_bucket: db_replica_bucket,
        shard: shard,
        readonly: readonly,
        name: name
      ) do
    GenServer.start_link(
      __MODULE__,
      %{db: db, db_replica_bucket: db_replica_bucket, shard: shard, readonly: readonly},
      name: name
    )
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

  def handle_call({:set, key, value}, _, %{db: db, db_replica_bucket: db_replica_bucket} = state) do
    :ok = CubDB.put(db, key, value)
    {:reply, CubDB.put(db_replica_bucket, key, value), state}
  end

  def handle_call({:set_update, key, value}, _, %{readonly: true, db: db} = state) do
    {:reply, CubDB.put(db, key, value), state}
  end

  def handle_call(:delete_extra, _from, %{db: db, shard: shard} = state) do
    extra_keys =
      CubDB.select(db)
      |> Stream.filter(fn {key, _value} -> !GenServer.call(shard, {:current, key}) end)
      |> Enum.to_list()

    {:reply, CubDB.delete_multi(db, extra_keys), state}
  end

  def handle_call(:next_replica_update, _from, %{db_replica_bucket: db_replica_bucket} = state) do
    {:reply, CubDB.select(db_replica_bucket) |> Enum.take(1), state}
  end

  def handle_call(
        {:replica_updated, key, value},
        _,
        %{db: db, db_replica_bucket: db_replica_bucket} = state
      ) do
    current_value = CubDB.get(db, key)

    if current_value != value do
      {:reply, :old_value, state}
    else
      Logger.info("Deleting replicated key #{key} from replica bucket", worker: state.name)
      {:reply, CubDB.delete(db_replica_bucket, key), state}
    end
  end
end

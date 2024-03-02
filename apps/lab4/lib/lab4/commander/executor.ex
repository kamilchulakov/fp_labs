defmodule Lab4.Commander.Executor do
  require Logger
  alias Lab4.DB

  def execute({:get, key}, state) do
    shard_key = DB.Shard.key_to_shard_key(state.shard, key)

    if shard_key == state.shard_key do
      DB.Worker.get(state.db_worker, key)
    else
      {:wrong_shard, shard_key}
    end
  end

  def execute({:set, key, value}, state) do
    case DB.Worker.set(state.db_worker, key, value) do
      :ok -> DB.Index.update_all(state.db_index, key, value)
      other -> other
    end
  end

  def execute(:purge, state) do
    DB.Worker.purge(state.db_worker)
    DB.Index.purge(state.db_index)
  end

  def execute({:create_index, name, filter}, state) do
    DB.Index.create(state.db_index, name, filter)
  end
end

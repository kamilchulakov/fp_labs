defmodule Lab4.Commander.Executor do
  require Logger
  alias Lab4.DB

  def execute({:get, key}, state) do
    shard_key = DB.Shard.key_to_shard_key(state.shard, key)

    if shard_key == state.shard_key do
      DB.Worker.get(state.db_worker, key)
    else
      {:error, {:wrong_shard, shard_key}}
    end
  end

  def execute({:set, key, value}, state) do
    shard_key = DB.Shard.key_to_shard_key(state.shard, key)

    if shard_key == state.shard_key do
      case DB.Worker.set(state.db_worker, key, value) do
        :ok -> DB.Index.update_all(state.db_index, key, value)
        other -> other
      end
    else
      {:error, {:wrong_shard, shard_key}}
    end
  end

  def execute(:purge, state) do
    deleted_keys = DB.Worker.purge(state.db_worker)
    DB.Index.delete(state.db_index, deleted_keys)
  end

  def execute({:create_index, name, filter, :global, command}, state) do
    DB.Index.create(state.db_index, name, filter, command)
  end

  def execute({:create_index, name, filter}, state) do
    DB.Index.create_local(state.db_index, name, filter)
  end

  def execute({:delete_index, name, :global, _command}, state) do
    DB.Index.delete(state.db_index, name)
  end

  def execute({:delete_index, name}, state) do
    DB.Index.delete_local(state.db_index, name)
  end

  def execute({:fetch_index, name, :global, _command}, state) do
    Logger.debug("Executing index fetch: #{name}", shard: state.shard_key)
    DB.Index.fetch(state.db_index, name)
  end

  def execute({:fetch_index, name}, state) do
    Logger.debug("Executing local index fetch: #{name}", shard: state.shard_key)
    DB.Index.fetch_local(state.db_index, name)
  end
end

defmodule Lab4.DB.Index do
  use GenServer

  require Logger
  require Jason
  alias Lab4.DB

  def start_link(
        bucket: bucket,
        db_worker: db_worker,
        shard_key: shard_key,
        name: name
      ) do
    GenServer.start_link(
      __MODULE__,
      %{
        bucket: bucket,
        db_worker: db_worker,
        shard_key: shard_key
      },
      name: name
    )
  end

  def create_local(pid, name, filter) do
    GenServer.call(pid, {:create_local, name, filter})
  end

  def delete_local(pid, names) when is_list(names) do
    GenServer.call(pid, {:delete_multi, names})
  end

  def delete_local(pid, name) do
    GenServer.call(pid, {:delete_local, name})
  end

  def update_all(pid, key, value) do
    GenServer.call(pid, {:update_all, key, value})
  end

  def fetch_local(pid, name) do
    GenServer.call(pid, {:fetch_local, name})
  end

  def init(state) do
    indices =
      CubDB.select(state.bucket)
      |> Stream.map(fn {index_name, _index_data} -> index_name end)
      |> Enum.to_list()
      |> Enum.join(", ")

    Logger.debug("Indices: #{indices}", shard: state.shard_key)

    {:ok, state}
  end

  def handle_call({:create_local, name, filter}, _from, state) do
    {:reply, new_index(name, filter, state), state}
  end

  def handle_call({:delete_local, name}, _from, state) do
    {:reply, CubDB.delete(state.bucket, name), state}
  end

  def handle_call({:delete_multi, names}, _from, state) do
    {:reply, CubDB.delete_multi(state.bucket, names), state}
  end

  def handle_call({:fetch_local, name}, _from, state) do
    {:reply, get_data(name, state), state}
  end

  def handle_call({:update_all, key, value}, _from, state) do
    CubDB.select(state.bucket)
    |> Stream.each(fn {index_key, {filter, _data}} = index ->
      if DB.Filter.matches?({key, value}, filter) do
        update(state, index, {key, value})
      else
        Logger.debug("Skipped index #{index_key} for update", shard: state.shard_key)
      end
    end)

    {:reply, :ok, state}
  end

  defp new_index(name, filter, state) do
    data = DB.Worker.filter(state.db_worker, filter)

    case CubDB.put_new(state.bucket, name, {filter, data}) do
      :ok ->
        Logger.debug("New index #{name} created: #{inspect(filter)}, #{inspect(data)}",
          shard: state.shard_key
        )

      error ->
        error
    end
  end

  defp update(state, {index_key, index_data}, new_entry) do
    Logger.debug("Index #{index_key} update: #{inspect(new_entry)}", shard: state.shard_key)
    CubDB.update(state.bucket, index_key, index_data, &update_data(&1, new_entry))
  end

  defp update_data({filter, data}, {key, _value} = new_entry) do
    new_data =
      data
      |> Enum.map(fn {entry_key, _} = entry ->
        if entry_key == key do
          new_entry
        else
          entry
        end
      end)

    {filter, new_data}
  end

  defp get_data(name, state) do
    case CubDB.get(state.bucket, name) do
      {_, data} ->
        data

      nil ->
        Logger.debug("Local index #{name} not found", shard: state.shard_key)
        {:error, :not_found}
    end
  end
end

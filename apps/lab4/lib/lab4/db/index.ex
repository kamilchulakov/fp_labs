defmodule Lab4.DB.Index do
  use GenServer

  require Logger
  alias Lab4.DB

  def start_link(bucket: bucket, db_worker: db_worker, name: name) do
    GenServer.start_link(__MODULE__, %{bucket: bucket, db_worker: db_worker}, name: name)
  end

  def create(pid, name, filter) do
    GenServer.call(pid, {:create, name, filter})
  end

  def delete(pid, names) when is_list(names) do
    GenServer.call(pid, {:delete_multi, names})
  end

  def delete(pid, name) do
    GenServer.call(pid, {:delete, name})
  end

  def update_all(pid, key, value) do
    GenServer.call(pid, {:update_all, key, value})
  end

  def fetch(pid, name) do
    GenServer.call(pid, {:fetch, name})
  end

  def init(state) do
    indices =
      CubDB.select(state.bucket)
      |> Stream.map(fn {index_name, _index_data} -> index_name end)
      |> Enum.to_list()
      |> Enum.join(", ")

    Logger.debug('Indices: #{indices}')

    {:ok, state}
  end

  def handle_call({:create, name, filter}, _from, state) do
    {:reply, new_index(name, filter, state), state}
  end

  def handle_call({:delete, name}, _from, state) do
    {:reply, CubDB.delete(state.bucket, name), state}
  end

  def handle_call({:delete_multi, names}, _from, state) do
    {:reply, CubDB.delete_multi(state.bucket, names), state}
  end

  def handle_call({:fetch, name}, _from, state) do
    case CubDB.get(state.bucket, name) do
      {_, data} -> {:reply, data, state}
      nil -> {:reply, {:error, :not_found}, state}
    end
  end

  def handle_call({:update_all, key, value}, _from, state) do
    CubDB.select(state.bucket)
    |> Stream.each(fn {index_key, {filter, _data}} = index ->
      if DB.Filter.matches?({key, value}, filter) do
        update(state, index, {key, value})
      else
        Logger.debug("Skipped index #{index_key} for update")
      end
    end)

    {:reply, :ok, state}
  end

  defp new_index(name, filter, state) do
    data = DB.Worker.filter(state.db_worker, filter)
    case CubDB.put_new(state.bucket, name, {filter, data}) do
      :ok -> Logger.debug("New index #{name} created: #{inspect(filter)}, #{inspect(data)}")
      error -> error
    end
  end

  defp update(state, {index_key, index_data}, new_entry) do
    Logger.debug("Index #{index_key} update: #{inspect(new_entry)}")
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
end

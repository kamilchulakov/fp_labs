defmodule Lab4.Commander.Executor do
  require Logger
  alias Lab4.DB

  def execute(state, {:get, [key]}), do: get(state, key)

  def execute(state, {:set, [key, value]}) do
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

  def execute(state, :purge) do
    deleted_keys = DB.Worker.purge(state.db_worker)
    DB.Index.delete_local(state.db_index, deleted_keys)
  end

  def execute(state, {:delete_keys, [key]}) do
    shard_key = DB.Shard.key_to_shard_key(state.shard, key)

    if shard_key == state.shard_key do
      case DB.Worker.delete(state.db_worker, key) do
        :ok -> DB.Index.delete_keys(state.db_index, key)
        other -> other
      end
    else
      {:error, {:wrong_shard, shard_key}}
    end
  end

  def execute(state, {:delete_keys, keys}) do
    other_shards =
      keys
      |> Enum.map(&DB.Shard.key_to_shard_key(state.shard, &1))
      |> Enum.filter(&(&1 != state.shard_key))

    case other_shards do
      [] ->
        case DB.Worker.delete(state.db_worker, keys) do
          :ok -> DB.Index.delete_keys(state.db_index, keys)
          other -> other
        end

      _ ->
        {:error, :other_shard_keys}
    end
  end

  def execute(state, {:delete_index, [index_name: name]}) do
    DB.Index.delete_local(state.db_index, name)
  end

  def execute(state, {:create_index, [{_index_name, name}, filter]}) do
    DB.Index.create_local(state.db_index, name, filter)
  end

  def execute(state, {:fetch_index, [index_name: name]}) do
    DB.Index.fetch_local(state.db_index, name)
  end

  def execute(state, {:lpush, [key, value]}) do
    case get_list(state, key) do
      {:error, reason} ->
        {:error, reason}

      list ->
        DB.Worker.set(state.db_worker, key, List.insert_at(list, 0, value))
    end
  end

  def execute(state, {:lpop, [key]}) do
    case get_list(state, key) do
      {:error, reason} ->
        {:error, reason}

      list ->
        {_, new_list} = List.pop_at(list, 0)
        DB.Worker.set(state.db_worker, key, new_list)
    end
  end

  def execute(_state, {:lmove, [key, key, direction, direction]}), do: :ok

  def execute(state, {:lmove, [key1, key2, direction1, direction2]}) do
    list1 = get_list(state, key1)
    list2 = get_list(state, key2)

    case list1 do
      {:error, reason} ->
        {:error, reason}

      [] ->
        {:error, :empty_list}

      _ ->
        {new_list1, new_list2} = move(list1, list2, direction1, direction2)
        DB.Worker.set(state.db_worker, key1, new_list1)
        DB.Worker.set(state.db_worker, key2, new_list2)
    end
  end

  def execute(state, {:llen, [key]}) do
    case get_list(state, key) do
      {:error, reason} -> {:error, reason}
      list -> length(list)
    end
  end

  def execute(state, {:ltrim, [key, stop]}) do
    case get_list(state, key) do
      {:error, reason} ->
        {:error, reason}

      list ->
        DB.Worker.set(state.db_worker, key, Enum.take(list, stop + 1))
    end
  end

  def execute(state, {:ltrim, [key, start, stop]}) do
    case get_list(state, key) do
      {:error, reason} ->
        {:error, reason}

      list ->
        DB.Worker.set(state.db_worker, key, list |> Enum.drop(start - 1) |> Enum.take(stop))
    end
  end

  def execute(state, {:rpush, [key, value]}) do
    case get_list(state, key) do
      {:error, reason} ->
        {:error, reason}

      list ->
        DB.Worker.set(state.db_worker, key, List.insert_at(list, -1, value))
    end
  end

  def execute(state, {:rpop, [key]}) do
    case get_list(state, key) do
      {:error, reason} ->
        {:error, reason}

      list ->
        {_, new_list} = List.pop_at(list, -1)
        DB.Worker.set(state.db_worker, key, new_list)
    end
  end

  def execute(state, local: local_command, global: global_command, type: :ok) do
    data =
      execute_global(state, global_command, parse: :ok)
      |> Enum.concat([execute(state, local_command)])
      |> List.flatten()
      |> Enum.uniq()

    case data do
      [:ok] -> :ok
      _ -> {:error, :bad_gateway}
    end
  end

  def execute(state, local: local_command, global: global_command, type: :concat) do
    execute_global(state, global_command, parse: :json)
    |> Enum.concat([execute(state, local_command)])
    |> Enum.reduce(&Enum.concat/2)
  end

  def execute_global(state, command, parse: parse_type) do
    Logger.debug("Executing global #{command}", shard: state.shard_key)

    call_global(state, command)
    |> Enum.map(fn {:ok, resp} ->
      parse_resp(resp, parse_type)
    end)
  end

  defp call_global(state, command) do
    state.addresses
    |> Enum.map(&Finch.build(:post, "#{&1}/", [], command, []))
    |> Enum.map(&Finch.request(&1, state.http_client))
  end

  defp parse_resp(resp, :ok) do
    if resp.body == "OK" do
      :ok
    else
      Logger.error("Not ok: #{inspect(resp)}")
      :nok
    end
  end

  defp parse_resp(resp, :json) do
    case Jason.decode(resp.body) do
      {:ok, fetch_data} ->
        fetch_data

      {:error, _reason} ->
        Logger.error("Error on decode: #{inspect(resp)}")
        []
    end
  end

  defp get(state, key, default \\ nil) do
    shard_key = DB.Shard.key_to_shard_key(state.shard, key)

    if shard_key == state.shard_key do
      case DB.Worker.get(state.db_worker, key, default) do
        nil -> {:error, :not_found}
        value -> value
      end
    else
      {:error, {:wrong_shard, shard_key}}
    end
  end

  defp get_list(state, key) do
    case get(state, key, []) do
      {:error, reason} ->
        {:error, reason}

      [_ | _] = list ->
        list

      [] ->
        []

      _ ->
        {:error, :not_a_list}
    end
  end

  defp move(list1, list2, :left, :left) do
    {element, new_list1} = List.pop_at(list1, 0)
    {new_list1, List.insert_at(list2, 0, element)}
  end

  defp move(list1, list2, :left, :right) do
    {element, new_list1} = List.pop_at(list1, 0)
    {new_list1, List.insert_at(list2, -1, element)}
  end

  defp move(list1, list2, :right, :left) do
    {element, new_list1} = List.pop_at(list1, -1)
    {new_list1, List.insert_at(list2, 0, element)}
  end

  defp move(list1, list2, :right, :right) do
    {element, new_list1} = List.pop_at(list1, -1)
    {new_list1, List.insert_at(list2, -1, element)}
  end
end

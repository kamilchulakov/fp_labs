defmodule Lab4.Commander.Executor do
  require Logger
  alias Lab4.DB

  def execute(state, {:get, key}) do
    shard_key = DB.Shard.key_to_shard_key(state.shard, key)

    if shard_key == state.shard_key do
      DB.Worker.get(state.db_worker, key)
    else
      {:error, {:wrong_shard, shard_key}}
    end
  end

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

  def execute(state, {:delete_index, [index_name: name]}) do
    DB.Index.delete_local(state.db_index, name)
  end

  def execute(state, {:create_index, [{_index_name, name}, filter]}) do
    DB.Index.create_local(state.db_index, name, filter)
  end

  def execute(state, {:fetch_index, [index_name: name]}) do
    Logger.debug("Executing local index fetch: #{name}", shard: state.shard_key)
    DB.Index.fetch_local(state.db_index, name)
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
end

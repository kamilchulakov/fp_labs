defmodule Lab4.Commander.Worker do
  use GenServer

  require Logger
  alias Lab4.Commander.Executor
  alias Lab4.Commander.Parser

  def start_link(
        db_worker: db_worker,
        db_index: db_index,
        shard: shard,
        shard_key: shard_key,
        name: name
      ) do
    GenServer.start_link(
      __MODULE__,
      %{db_worker: db_worker, db_index: db_index, shard: shard, shard_key: shard_key},
      name: name
    )
  end

  def execute(pid, command) do
    GenServer.call(pid, command)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(command, _from, state) do
    case Parser.parse(command) do
      :bad_args ->
        {:error, :bad_args} |> to_reply(state)

      data ->
        try do
          Executor.execute(data, state) |> to_reply(state)
        rescue
          FunctionClauseError ->
            to_reply({:error, :not_implemented}, state)

          Jason.DecodeError ->
            to_reply({:error, :invalid_json}, state)
        end
    end
  end

  defp to_reply(data, state) do
    {:reply, data, state}
  end
end

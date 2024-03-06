defmodule Lab4.Commander.Worker do
  @moduledoc """
  Module for parsing and executing commands.
  """

  use GenServer

  require Logger
  alias Lab4.Commander.Executor
  alias Lab4.Commander.Parser

  def start_link(
        db_worker: db_worker,
        db_index: db_index,
        shard: shard,
        shard_key: shard_key,
        addresses: addresses,
        http_client: http_client,
        name: name
      ) do
    GenServer.start_link(
      __MODULE__,
      %{
        db_worker: db_worker,
        db_index: db_index,
        shard: shard,
        shard_key: shard_key,
        addresses: addresses,
        http_client: http_client,
        name: name
      },
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
    case Parser.parse_and_put_opts(command) do
      {:error, reason} ->
        to_reply({:error, reason}, state)

      parsed_command ->
        Logger.debug("Parsed command: #{inspect(parsed_command)}", worker: state.name)

        try do
          Executor.execute(state, parsed_command) |> to_reply(state)
        rescue
          Jason.DecodeError ->
            to_reply({:error, :invalid_json}, state)
        end
    end
  end

  defp to_reply(data, state) do
    {:reply, data, state}
  end
end

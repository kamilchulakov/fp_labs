defmodule Lab4.DB.Replica do
  @moduledoc """
  Module for replica logic: ask for updates and call db update in a loop
  """

  require Logger
  use GenServer

  @sleep_ms 1000
  @error_sleep_ms 5000

  def start_link(
        http_client: http_client,
        leader_addr: leader_addr,
        db_worker: db_worker,
        name: name
      ) do
    GenServer.start_link(
      __MODULE__,
      %{http_client: http_client, leader_addr: leader_addr, db_worker: db_worker, name: name},
      name: name
    )
  end

  @impl true
  def init(state) do
    {:ok, state, {:continue, :ask_for_next_update}}
  end

  @impl true
  def handle_continue(:ask_for_next_update, state) do
    Finch.build(:get, "#{state.leader_addr}/next-replica-update")
    |> Finch.request(state.http_client)
    |> handle_next_update_response(state)

    Process.sleep(@sleep_ms)

    {:noreply, state, {:continue, :ask_for_next_update}}
  end

  defp handle_next_update_response({:ok, response}, state) when response.body == "" do
    Logger.info("#{state.leader_addr} has no updates", worker: state.name)
  end

  defp handle_next_update_response({:ok, response}, state) do
    [key, value] = String.split(response.body, "=")
    Logger.info("Got update", worker: state.name)
    GenServer.call(state.db_worker, {:set_update, key, value})

    Finch.build(:post, "#{state.leader_addr}/replica-updated/#{key}/#{value}")
    |> Finch.request(state.http_client)
  end

  defp handle_next_update_response({:error, error}, state) do
    Logger.error("Failed to fetch update from #{state.leader_addr}: #{inspect(error)}",
      worker: state.name
    )

    Process.sleep(@error_sleep_ms)
  end
end

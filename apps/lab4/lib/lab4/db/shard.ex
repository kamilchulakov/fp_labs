defmodule Lab4.DB.Shard do
  @moduledoc """
  Provides shard information.
  """

  use GenServer

  def start_link(shards: shards, name: name) do
    GenServer.start_link(__MODULE__, shards, name: name)
  end

  def key_to_shard_key(pid, key) do
    GenServer.call(pid, {:key_to_shard, key})
  end

  def belongs_to_current?(pid, key) do
    GenServer.call(pid, {:current, key})
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:key_to_shard, key}, _from, state) do
    {:reply, key_to_shard(key, state.count), state}
  end

  def handle_call({:current, key}, _from, state) do
    {:reply, key_to_shard(key, state.count) == state.current.shard_key, state}
  end

  defp key_to_shard(key, count) do
    :erlang.phash2(key)
    |> Integer.mod(count)
  end
end

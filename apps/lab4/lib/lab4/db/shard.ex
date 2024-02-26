defmodule Lab4.DB.Shard do
  use GenServer

  def start_link(shards: shards, name: name) do
    GenServer.start_link(__MODULE__, shards, name: name)
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:key_to_shard, key}, _from, state) do
    {:reply, key_to_shard(key, state.count), state}
  end

  defp key_to_shard(key, count) do
    :erlang.phash2(key)
    |> Integer.mod(count)
  end
end

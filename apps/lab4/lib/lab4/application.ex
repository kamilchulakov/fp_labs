defmodule Lab4.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  require Logger

  alias Lab4.Config
  alias Lab4.DB
  alias Lab4.Http

  use Application

  def main(args) do
    {:ok, pid} = start(:normal, args)

    Process.link(pid)
    :timer.sleep(:infinity)
  end

  @impl true
  def start(_type, args) do
    config = Config.new(args)
    shard = config.shards.current

    Logger.info("Hello! My name is #{shard.name}", shard: shard.index)

    opts = [strategy: :one_for_one, name: Lab4.Supervisor]
    Supervisor.start_link(children(config, shard), opts)
  end

  defp children(config, shard) when config.replica == true do
    names = names(shard)

    [
      {CubDB, [data_dir: config.data_dir, name: names[:db]]},
      {Finch, name: names[:http_client]},
      {DB.Replica,
       http_client: names[:http_client],
       leader_addr: addresses(config.shards)[shard.index],
       db_worker: names[:db_worker],
       name: names[:replica]},
      {Plug.Cowboy,
       scheme: :http,
       plug: {Http.Router, %{names: names, shard: shard, addresses: addresses(config.shards)}},
       options: [port: config.port]},
      {DB.Worker,
       db: names[:db], shard: names[:shard], readonly: config.replica, name: names[:db_worker]},
      {DB.Shard, shards: config.shards, name: names[:shard]}
    ]
  end

  defp children(config, shard) when config.replica == false do
    names = names(shard)

    [
      Supervisor.child_spec({CubDB, [data_dir: config.data_dir, name: names[:db]]},
        id: names[:db]
      ),
      Supervisor.child_spec(
        {CubDB, [data_dir: "#{config.data_dir}/replica-bucket", name: names[:db_replica_bucket]]},
        id: names[:db_replica_bucket]
      ),
      {Plug.Cowboy,
       scheme: :http,
       plug: {Http.Router, %{names: names, shard: shard, addresses: addresses(config.shards)}},
       options: [port: config.port]},
      {DB.Worker,
       db: names[:db],
       db_replica_bucket: names[:db_replica_bucket],
       shard: names[:shard],
       readonly: config.replica,
       name: names[:db_worker]},
      {DB.Shard, shards: config.shards, name: names[:shard]}
    ]
  end

  defp names(shard) do
    %{
      db: String.to_atom("db"),
      db_replica_bucket: String.to_atom("db_replica_bucket"),
      db_worker: String.to_atom("db_worker"),
      router: String.to_atom("router"),
      shard: String.to_atom("shard-#{shard.index}"),
      http_client: String.to_atom("http_client"),
      replica: String.to_atom("replica-#{shard.index}")
    }
  end

  defp addresses(shards) do
    shards.list
    |> Enum.into(Map.new(), &{&1.index, "http://#{&1.address}"})
  end
end

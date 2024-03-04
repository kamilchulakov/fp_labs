defmodule Lab4.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  require Logger

  alias Lab4.Commander
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

    opts = [strategy: :one_for_one, name: Lab4.Supervisor]
    Supervisor.start_link(children(config, shard), opts)
  end

  defp children(config, shard) when config.replica == true do
    Logger.info("Replica starting", shard: shard.shard_key)
    names = names(shard)

    [
      {CubDB, [data_dir: config.data_dir, name: names[:db]]},
      {Finch, name: names[:http_client]},
      {DB.Replica,
       http_client: names[:http_client],
       leader_addr: addresses(config.shards)[shard.shard_key],
       db_worker: names[:db_worker],
       name: names[:replica]},
      {Plug.Cowboy,
       scheme: :http,
       plug: {Http.Router, %{pids: names, shard: shard, addresses: addresses(config.shards)}},
       options: [port: config.port]},
      {DB.Worker, db: names[:db], shard: names[:shard], name: names[:db_worker]},
      {DB.Shard, shards: config.shards, name: names[:shard]}
    ]
  end

  defp children(config, shard) when config.replica == false do
    Logger.info("Hello! My name is #{shard.name}", shard: shard.shard_key)
    names = names(shard)

    [
      Supervisor.child_spec({CubDB, [data_dir: config.data_dir, name: names[:db]]},
        id: names[:db]
      ),
      Supervisor.child_spec(
        {CubDB, [data_dir: "#{config.data_dir}/replica-bucket", name: names[:db_replica_bucket]]},
        id: names[:db_replica_bucket]
      ),
      Supervisor.child_spec(
        {CubDB, [data_dir: "#{config.data_dir}/index-bucket", name: names[:db_index_bucket]]},
        id: names[:db_index_bucket]
      ),
      {Commander.Worker,
       db_worker: names[:db_worker],
       db_index: names[:db_index],
       shard: names[:shard],
       shard_key: shard.shard_key,
       addresses: external_addresses(config.shards, shard),
       http_client: names[:http_client],
       name: names[:commander]},
      {Finch,
       name: names[:http_client],
       pools: %{
         :default => [size: map_size(config.shards)]
       }},
      {Plug.Cowboy,
       scheme: :http,
       plug:
         {Http.Router,
          %{
            db_worker: names[:db_worker],
            shard: shard,
            commander: names[:commander],
            addresses: addresses(config.shards)
          }},
       options: [port: config.port]},
      {DB.Index,
       bucket: names[:db_index_bucket],
       db_worker: names[:db_worker],
       shard_key: shard.shard_key,
       name: names[:db_index]},
      {DB.Worker,
       db: names[:db],
       db_replica_bucket: names[:db_replica_bucket],
       shard: names[:shard],
       name: names[:db_worker]},
      {DB.Shard, shards: config.shards, name: names[:shard]}
    ]
  end

  defp names(shard) do
    %{
      db: String.to_atom("db"),
      db_replica_bucket: String.to_atom("db_replica_bucket"),
      db_worker: String.to_atom("db_worker-#{shard.shard_key}"),
      db_index: String.to_atom("db_index"),
      db_index_bucket: String.to_atom("db_index_bucket"),
      router: String.to_atom("router-#{shard.shard_key}"),
      shard: String.to_atom("shard-#{shard.shard_key}"),
      http_client: String.to_atom("http_client-#{shard.shard_key}"),
      replica: String.to_atom("replica-#{shard.shard_key}"),
      commander: String.to_atom("commander-#{shard.shard_key}")
    }
  end

  defp addresses(shards) do
    shards.list
    |> Enum.into(Map.new(), &{&1.shard_key, "http://#{&1.address}"})
  end

  defp external_addresses(shards, current) do
    addresses(shards)
    |> Map.values()
    |> Enum.filter(&(!String.ends_with?(&1, current.address)))
  end
end

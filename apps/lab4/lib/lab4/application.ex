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

    Logger.info("Hello! My name is #{shard.name}", [shard: shard.index])

    names = names(shard)

    children = [
      {CubDB, [data_dir: config.data_dir, name: names[:db]]},
      {Plug.Cowboy,
       scheme: :http,
       plug: {Http.Router, %{names: names, shard: shard, addresses: addresses(config.shards)}},
       options: [port: config.port]},
      {DB.Worker, db: names[:db], shard: names[:shard], readonly: config.replica, name: names[:db_worker]},
      {DB.Shard, shards: config.shards, name: names[:shard]}
    ]

    opts = [strategy: :one_for_one, name: Lab4.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp names(current_shard) do
    %{
      db: String.to_atom("db-#{current_shard.index}"),
      db_worker: String.to_atom("db_worker-#{current_shard.index}"),
      router: String.to_atom("router-#{current_shard.index}"),
      shard: String.to_atom("shard-#{current_shard.index}")
    }
  end

  defp addresses(shards) do
    shards.list
    |> Enum.into(Map.new(), &({&1.index, "http://#{&1.address}"}))
  end
end

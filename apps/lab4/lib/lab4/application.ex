defmodule Lab4.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  @port 8081
  @shard "Saint-Petersburg"

  require Logger

  use Application

  @impl true
  def start(_type, _args) do
    config =
      Lab4.Config.new(
        path: "conf/sharding.toml",
        data_dir: "db/data",
        port: @port,
        shard: @shard
      )

    if config.shards.current == nil do
      Logger.error("Shard with name \"#{@shard}\" not found.")
      exit(-1)
    end

    Logger.info("Hello! My name is #{config.shards.current.name}")

    names = names(config.shards.current)

    children = [
      {CubDB, [data_dir: config.data_dir, name: names[:db]]},
      {Plug.Cowboy, scheme: :http, plug: {Lab4.Http.Router, names}, options: [port: config.port]},
      {Lab4.DB.Worker, db: names[:db], name: names[:db_worker]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lab4.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp names(current_shard) do
    %{
      db: String.to_atom("db-#{current_shard.index}"),
      db_worker: String.to_atom("db_worker-#{current_shard.index}"),
      router: String.to_atom("router-#{current_shard.index}")
    }
  end
end

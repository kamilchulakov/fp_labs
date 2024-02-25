defmodule Lab4.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  @port 8080
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

    {:ok, db} = CubDB.start_link(config.data_dir)

    children = [
      {Plug.Cowboy, scheme: :http, plug: Lab4.Http.Router, options: [port: config.port]},
      {Lab4.DB.Worker, db: db}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lab4.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

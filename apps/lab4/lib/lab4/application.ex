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

    Logger.info("Hello! My name is #{config.shards.current.name}")

    names = names(config.shards.current)

    children = [
      {CubDB, [data_dir: config.data_dir, name: names[:db]]},
      {Plug.Cowboy, scheme: :http, plug: {Http.Router, names}, options: [port: config.port]},
      {DB.Worker, db: names[:db], name: names[:db_worker]},
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
end

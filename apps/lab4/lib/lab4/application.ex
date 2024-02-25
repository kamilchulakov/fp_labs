defmodule Lab4.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    {:ok, db} = CubDB.start_link(data_dir: "db/data")

    children = [
      {Plug.Cowboy, scheme: :http, plug: Lab4.Http.Router, options: [port: 8080]},
      {Lab4.Db.Worker, db: db}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lab4.Supervisor]
    Supervisor.start_link(children, opts)
  end
end

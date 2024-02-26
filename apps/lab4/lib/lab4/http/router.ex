defmodule Lab4.Http.Router do
  use Plug.Router

  alias Lab4.DB

  plug :match
  plug :dispatch

  def init(opts), do: opts

  match "/get/:key" do
    value = GenServer.call(conn.private.opts.db_worker, {:get, key})
    # DB.Shard.key_shard(key, opts[:count])
    send_resp(conn, 200, "Get #{key}: #{value}")
  end

  match "set/:key/:value" do
    GenServer.call(conn.private.opts.db_worker, {:set, key, value})
    send_resp(conn, 200, "Set #{key}=#{value}")
  end

  def call(conn, opts) do
    put_private(conn, :opts, opts)
    |> super(opts)
  end
end

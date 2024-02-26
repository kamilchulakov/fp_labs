defmodule Lab4.Http.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  def init(opts), do: opts

  match "/get/:key" do
    opts = conn.private.opts
    value = GenServer.call(opts.db_worker, {:get, key})
    shard_index = GenServer.call(opts.shard, {:key_to_shard, key})
    send_resp(conn, 200, "Get #{key}=#{value} on shard #{shard_index}")
  end

  match "set/:key/:value" do
    GenServer.call(conn.private.opts.db_worker, {:set, key, value})
    send_resp(conn, 200, "Set #{key}=#{value}")
  end

  # Ugly workaround to get opts (passed to init/1) in route handlers.
  def call(conn, opts) do
    put_private(conn, :opts, opts)
    |> super(opts)
  end
end

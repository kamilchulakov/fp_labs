defmodule Lab4.Http.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  def init(opts), do: opts

  match "/get/:key" do
    opts = conn.private.opts
    shard_index = GenServer.call(opts.names.shard, {:key_to_shard, key})

    if shard_index != opts.shard.index do
      conn
      |> Plug.Conn.resp(:found, "")
      |> Plug.Conn.put_resp_header("location", "https://www.google.com")
    else
      value = GenServer.call(opts.names.db_worker, {:get, key})
      send_resp(conn, 200, "Get #{key}=#{value} on shard #{shard_index}")
    end
  end

  match "set/:key/:value" do
    opts = conn.private.opts
    shard_index = GenServer.call(opts.names.shard, {:key_to_shard, key})

    if shard_index != opts.shard.index do
      conn
      |> Plug.Conn.resp(:found, "")
      |> Plug.Conn.put_resp_header("location", "https://www.google.com")
    else
      GenServer.call(opts.names.db_worker, {:set, key, value})
      send_resp(conn, 200, "Set #{key}=#{value}")
    end
  end

  # Ugly workaround to get opts (passed to init/1) in route handlers.
  def call(conn, opts) do
    put_private(conn, :opts, opts)
    |> super(opts)
  end
end

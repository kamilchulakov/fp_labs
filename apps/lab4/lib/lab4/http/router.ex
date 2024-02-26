defmodule Lab4.Http.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  def init(opts), do: opts

  match "/get/:key" do
    opts = conn.private.opts
    shard_index = GenServer.call(opts.names.shard, {:key_to_shard, key})

    if shard_index != opts.shard.index do
      redirect_to(conn, shard_index)
    else
      value = GenServer.call(opts.names.db_worker, {:get, key})
      send_resp(conn, 200, "Get #{key}=#{value} on shard #{shard_index}")
    end
  end

  match "set/:key/:value" do
    opts = conn.private.opts
    shard_index = GenServer.call(opts.names.shard, {:key_to_shard, key})

    if shard_index != opts.shard.index do
      redirect_to(conn, shard_index)
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

  defp redirect_to(conn, shard_index) do
    conn
    |> Plug.Conn.resp(:found, "")
    |> Plug.Conn.put_resp_header("location", "#{replace_endpoint(conn, shard_index)}")
  end

  defp replace_endpoint(conn, shard_index) do
    opts = conn.private.opts
    addresses = opts.addresses

    conn
    |> Plug.Conn.request_url()
    |> String.replace(addresses[opts.shard.index], addresses[shard_index])
  end
end

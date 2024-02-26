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

  match "/set/:key/:value" do
    opts = conn.private.opts
    shard_index = GenServer.call(opts.names.shard, {:key_to_shard, key})

    if shard_index != opts.shard.index do
      redirect_to(conn, shard_index)
    else
      case GenServer.call(opts.names.db_worker, {:set, key, value}) do
        :ok -> send_resp(conn, 200, "Set #{key}=#{value}")
        :readonly -> send_resp(conn, 403, "Forbidden to modify replica data")
      end
    end
  end

  match "/purge" do
    opts = conn.private.opts

    GenServer.call(opts.names.db_worker, :delete_extra)
    send_resp(conn, 200, "Purged")
  end

  match "/next-replica-update" do
    opts = conn.private.opts
    [{key, value}] = GenServer.call(opts.names.db_worker, :next_replica_update)
    send_resp(conn, 200, "#{key}=#{value}")
  end

  match "/replica-updated/:key/:value" do
    opts = conn.private.opts

    case GenServer.call(opts.names.db_worker, {:replica_updated, key, value}) do
      :old_value -> send_resp(conn, 401, "Old value")
      :ok -> send_resp(conn, 200, "Deleted")
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

defmodule Lab4.Http.Router do
  @moduledoc """
  This module is doing its best in handling http requests.
  """

  require Logger
  alias Lab4.Commander
  alias Lab4.DB
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  def init(opts), do: opts

  match "/" do
    opts = conn.private.opts
    {:ok, command, conn} = Plug.Conn.read_body(conn)

    Logger.info(command, shard: opts.shard.shard_key)

    case Commander.Worker.execute(opts.commander, command) do
      :ok -> send_resp(conn, 200, "OK")
      {:error, {:wrong_shard, shard_key}} -> redirect_to(conn, shard_key)
      {:error, :bad_args} -> send_resp(conn, 403, "Bad request")
      {:error, :not_found} -> send_resp(conn, 404, "Not found")
      {:error, :exists} -> send_resp(conn, 409, "Exists")
      {:error, other} ->
        Logger.debug("Unhandled error: #{inspect(other)}", shard: opts.shard.shard_key)
        send_resp(conn, 500, "Internal error")
      data -> send_resp(conn, 200, inspect(data))
    end
  end

  match "/next-replica-update" do
    opts = conn.private.opts

    case DB.Worker.next_replica_update(opts.db_worker) do
      [] -> send_resp(conn, 200, "")
      [{key, value}] -> send_resp(conn, 200, "#{key}=#{value}")
      _ -> Logger.error("Invalid next update value")
    end
  end

  match "/replica-updated/:key/:value" do
    opts = conn.private.opts

    case DB.Worker.replica_updated(opts.db_worker, key, value) do
      :old_value -> send_resp(conn, 401, "Old value")
      :ok -> send_resp(conn, 200, "Deleted")
    end
  end

  # Ugly workaround to get opts (passed to init/1) in route handlers.
  def call(conn, opts) do
    put_private(conn, :opts, opts)
    |> super(opts)
  end

  defp redirect_to(conn, shard_key) do
    Logger.debug("Redirected to #{shard_key}", shard: conn.private.opts.shard.shard_key)

    conn
    |> Plug.Conn.resp(:found, "")
    |> Plug.Conn.put_resp_header("location", "#{replace_endpoint(conn, shard_key)}")
  end

  defp replace_endpoint(conn, shard_key) do
    opts = conn.private.opts
    addresses = opts.addresses

    conn
    |> Plug.Conn.request_url()
    |> String.replace(addresses[opts.shard.shard_key], addresses[shard_key])
  end
end

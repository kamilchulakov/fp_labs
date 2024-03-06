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
      :ok ->
        send_resp(conn, 200, "OK")

      {:error, {:wrong_shard, shard_key}} ->
        redirect_to(conn, shard_key, command)

      {:error, :other_shard_keys} ->
        send_resp(conn, 400, "Keyset contains other shard keys")

      {:error, :bad_args} ->
        send_resp(conn, 400, "Bad command")

      {:error, :not_a_list} ->
        send_resp(conn, 400, "Not a list")

      {:error, :empty_list} ->
        send_resp(conn, 400, "Empty list")

      {:error, :not_found} ->
        send_resp(conn, 404, "Not found")

      {:error, :exists} ->
        send_resp(conn, 409, "Exists")

      {:error, other} ->
        Logger.debug("Unhandled error: #{inspect(other)}", shard: opts.shard.shard_key)
        send_resp(conn, 500, "Internal error")

      data ->
        send_resp(conn, 200, Jason.encode!(data))
    end
  end

  get "/health" do
    send_resp(conn, 200, "OK")
  end

  match "/next-replica-update" do
    opts = conn.private.opts

    case DB.Worker.next_replica_update(opts.db_worker) do
      [] ->
        send_resp(conn, 200, "")

      [next_update] ->
        Logger.debug("Next replica update #{inspect(next_update)}", shard: opts.shard.shard_key)
        send_resp(conn, 200, Jason.encode!(next_update))

      _ ->
        Logger.error("Invalid next update value")
    end
  end

  match "/replica-updated" do
    opts = conn.private.opts
    {:ok, body, conn} = Plug.Conn.read_body(conn)

    [{key, value}] =
      Jason.decode!(body)
      |> Enum.map(& &1)

    Logger.debug("Replica updated")

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

  defp redirect_to(conn, shard_key, command) do
    Logger.debug("Redirected to #{shard_key}", shard: conn.private.opts.shard.shard_key)

    redirect_endpoint =
      replace_endpoint(conn, shard_key)

    redirect_resp =
      Finch.build(:post, redirect_endpoint, [], command)
      |> Finch.request!(conn.private.opts.http_client)

    conn
    |> Plug.Conn.put_resp_header("location", "#{redirect_endpoint}")
    |> Plug.Conn.send_resp(redirect_resp.status, redirect_resp.body)
  end

  defp replace_endpoint(conn, shard_key) do
    opts = conn.private.opts
    addresses = opts.addresses

    conn
    |> Plug.Conn.request_url()
    |> String.replace(addresses[opts.shard.shard_key], addresses[shard_key])
  end
end

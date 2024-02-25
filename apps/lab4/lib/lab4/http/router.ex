defmodule Lab4.Http.Router do
  use Plug.Router

  plug :match
  plug :dispatch

  match "/get/:key" do
    value = GenServer.call(Lab4.Db.Worker, {:get, key})
    send_resp(conn, 200, "Get #{key}: #{value}")
  end

  match "set/:key/:value" do
    GenServer.call(Lab4.Db.Worker, {:set, key, value})
    send_resp(conn, 200, "Set #{key}=#{value}")
  end
end

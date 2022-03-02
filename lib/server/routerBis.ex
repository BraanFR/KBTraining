defmodule Server.RouterBis do
  use Plug.Router
  require Logger

  plug Plug.Static, from: "priv/static", at: "/static"
  plug(:match)
  plug Plug.Parsers, parsers: [:urlencoded, {:json, json_decoder: Poison}]
  plug(:dispatch)

  get "/api/order/" do
    Logger.info("IN GET " <> conn.query_params["id"])
    result = Server.Database.read(Server.Database, conn.query_params["id"])

    result = case result do
      {:ok, value} -> value
      :error -> %{}
    end

    send_resp(conn, 200, Poison.encode!(result))
  end

  get "/api/orders" do
    Logger.info("IN GET READ ALL")
    result = Server.Database.read_all(Server.Database)

    result = case result do
      [] -> %{}
      _ -> result
    end

    send_resp(conn, 200, Poison.encode!(result))
  end

  get "/database/search" do
    result = Server.Database.search(Server.Database, [{conn.query_params["id"], conn.query_params["value"]}])

    result = case result do
      [] -> %{}
      _ -> result
    end

    send_resp(conn, 200, Poison.encode!(result))
  end

  put "/database" do
    Server.Database.update(Server.Database, conn.body_params["id"], conn.body_params["value"])

    result = Server.Database.read(Server.Database, conn.body_params["id"])
    result = case result do
      {:ok, value} -> value
      :error -> %{}
    end

    if result == conn.body_params["value"] do
      send_resp(conn, 200, Poison.encode!(result))
    else
      send_resp(conn, 418, "ELEMENT NOT FOUND IN DATABASE")
    end
  end

  post "/database" do
    Server.Database.create(Server.Database, conn.body_params["id"], conn.body_params["value"])

    result = Server.Database.read(Server.Database, conn.body_params["id"])
    case result do
      {:ok, value} -> send_resp(conn, 200, Poison.encode!(value))
      :error -> send_resp(conn, 418, "COULD NOT CREATE")
    end
  end

  delete "/database" do
    Logger.info("IN DELETE " <> conn.query_params["id"])
    Server.Database.delete(Server.Database, conn.query_params["id"])

    # result = Server.Database.read(Server.Database, conn.query_params["id"])
    # case result do
    #   {:ok, _value} -> send_resp(conn, 418, Poison.encode!("COULD NOT DELETE"))
    #   :error -> send_resp(conn, 200, Poison.encode!("SUCCESSFULY DELETED"))
    # end

    result = Server.Database.read_all(Server.Database)

    result = case result do
      [] -> %{}
      _ -> result
    end

    send_resp(conn, 200, Poison.encode!(result))

  end

  # get "/", do: send_resp(conn, 200, "Welcome")

  get _, do: send_file(conn, 200, "priv/static/index.html")

  # match _, do: send_resp(conn, 404, "Page Not Found")

end

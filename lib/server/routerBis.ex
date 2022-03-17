defmodule Server.RouterBis do
  use Plug.Router
  require Logger
  require EEx

  # plug Plug.Static, from: "priv/static", at: "/static"
  plug Plug.Static, at: "/public", from: :project
  plug(:match)
  plug Plug.Parsers, parsers: [:urlencoded, {:json, json_decoder: Poison}]
  plug(:dispatch)

  EEx.function_from_file :defp, :layout, "web/layout.html.eex", [:render]

  get "/api/order/" do
    Logger.info("IN GET " <> conn.query_params["id"])
    # result = Server.Database.read(Server.Database, conn.query_params["id"])

    result = Riak.get(conn.query_params["id"])

    # result = case result do
    #   {:ok, value} -> value
    #   :error -> %{}
    # end

    result = case result do
      {:ok, value} -> elem(value, 1)
      {:ko, _value} -> %{}
    end

    send_resp(conn, 200, Poison.encode!(result))
  end

  get "/api/orders" do
    Logger.info("IN GET READ ALL")
    # result = Server.Database.read_all(Server.Database)

    page = conn.query_params["page"]
    rows = conn.query_params["rows"]
    sort = conn.query_params["sort"]

    query = Enum.reduce(Map.keys(conn.query_params), "", fn x, acc ->
      if x not in ["page", "rows", "sort"] do
        acc <> "&" <> x <> ":" <> conn.query_params[x]
      else
        acc
      end
    end)

    query = if String.length(query) > 0 do
      String.slice(query, 1, String.length(query) - 1)
    else
      "*:*"
    end

    Logger.info(query)

    result = elem(Riak.search(Riak.index, query, page || 0, rows || 30, sort || "creation_date_index"), 1)["docs"]

    result = case result do
      [] -> %{}
      _ -> result
    end

    send_resp(conn, 200, Poison.encode!(result))
  end

  # get "/database/search" do
  #   result = Server.Database.search(Server.Database, [{conn.query_params["id"], conn.query_params["value"]}])

  #   result = case result do
  #     [] -> %{}
  #     _ -> result
  #   end

  #   send_resp(conn, 200, Poison.encode!(result))
  # end

  get "/pay" do
    Logger.info("IN GET " <> conn.query_params["id"])
    # result = Server.Database.read(Server.Database, conn.query_params["id"])

    pid = Server.DynSupervisor.get_child(conn.query_params["id"])

    result = TransitionGenServ.pay(pid)

    # result = case result do
    #   {:ok, value} -> value
    #   :error -> %{}
    # end

    result = case result do
      :action_unavailable -> %{}
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

    :timer.sleep(2000)

    send_resp(conn, 200, Poison.encode!(result))

  end

  # get "/", do: send_resp(conn, 200, "Welcome")

  # get _, do: send_file(conn, 200, "priv/static/index.html")

  # match _, do: send_resp(conn, 404, "Page Not Found")

  get _ do
    conn = fetch_query_params(conn)
    render = Reaxt.render!(:app, %{path: conn.request_path, cookies: conn.cookies, query: conn.params},30_000)
    send_resp(put_resp_header(conn, "content-type", "text/html;charset=utf-8"), render.param || 200, layout(render))
  end

end

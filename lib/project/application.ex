defmodule Project.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Project.Worker.start_link(arg)
      # {Project.Worker, arg}

      # {Plug.Cowboy, scheme: :http, plug: Server.TheFirstPlug, options: [port: 4001]}
      {Plug.Cowboy, scheme: :http, plug: Server.RouterBis, options: [port: 4001]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    # opts = [strategy: :one_for_one, name: Project.Supervisor]
    # Supervisor.start_link(children, opts)

    ServSupervisor.start_link([])
    Server.JsonLoader.load_to_database(Server.Database, "/home/vincent/Documents/Projects/KBRW/training/2021_12_30_formation/Formation/Resources/chap1/orders_dump/orders_chunk0.json")
    Supervisor.start_link(children, strategy: :one_for_one)
  end
end

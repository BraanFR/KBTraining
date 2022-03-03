defmodule ServSupervisor do
    use Supervisor

    # CLIENT

    def start_link(_) do
        Supervisor.start_link(__MODULE__, [], name: __MODULE__)
    end

    # SERVER

    def init(_) do
        children = [
            {Server.Database, name: Server.Database},
            {Riak, name: Riak}
        ]

        Supervisor.init(children, strategy: :one_for_one)
    end
end

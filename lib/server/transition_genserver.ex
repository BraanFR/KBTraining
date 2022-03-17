defmodule TransitionGenServ do
  use GenServer, restart: :transient
  require Logger

  def timeout, do: 1 * 60 * 1000

  def start_link(order_id) do
    GenServer.start_link(__MODULE__, order_id, [])
  end

  def init(order_id) do
    {:ok, elem(elem(Riak.get(order_id), 1), 1), TransitionGenServ.timeout}
  end

  def call(pid) do
    GenServer.call(pid, :get)
  end

  def pay(pid) do
    GenServer.call(pid, :pay)
  end

  def verify(pid) do
    GenServer.call(pid, :verify)
  end


  def handle_call(:get, _from, state) do
    {:reply, state, state, TransitionGenServ.timeout}
  end

  def handle_call(:pay, _from, state) do
    case ExFSM.Machine.event(state, {:process_payment, []}) do
      {:next_state, updated_order} ->
        Riak.put(state["id"], Poison.encode!(updated_order))

        {:reply, updated_order, updated_order, TransitionGenServ.timeout}

      _ -> {:reply, :action_unavailable, state, TransitionGenServ.timeout}
    end
  end

  def handle_call(:verify, _from, state) do
    case ExFSM.Machine.event(state, {:verification, []}) do
      {:next_state, updated_order} ->
        Riak.put(state["id"], Poison.encode!(updated_order))

        {:reply, updated_order, updated_order, TransitionGenServ.timeout}

      _ -> {:reply, :action_unavailable, state, TransitionGenServ.timeout}
    end
  end

  def handle_info(:timeout, _state) do
    Logger.info("TIMEOUT TRANSITIONGENSERV")

    # {:noreply, nil}
    {:stop, :shutdown, nil}
  end

end

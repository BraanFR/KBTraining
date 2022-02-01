defmodule Server.Database do
  use GenServer
  require Logger

  # CLIENT

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :database, opts)
  end

  def create(table, key, value) do
    GenServer.cast(table, {:create, key, value})
  end

  def read(table, key) do
    GenServer.call(table, {:read, key})
  end

  def update(table, key, value) do
    GenServer.cast(table, {:update, key, value})
  end

  def delete(table, key) do
    GenServer.cast(table, {:delete, key})
  end

  def search(table, criteria) do
    # Get all elements of the DB
    all_elements = elem(GenServer.call(table, {:readall}), 1)

    # Extract all the values that matches criterias
    result_set = Enum.reduce(criteria, MapSet.new([]), fn(crit, acc) ->
      {key, value} = crit
      elements = Enum.filter(all_elements, fn {_y, x} -> Enum.member?(Map.keys(x), key) && x[key] == value end)

      # updating the accumulator with the new values (but a Set, avoiding dupplicates)
      MapSet.union(acc, MapSet.new(elements))
    end)

    # Proper result presentation
    Enum.reduce(result_set, [], fn {_key, value}, acc -> [value | acc] end)
  end


  # SERVER

  @impl true
  def init(table) do
    pid = :ets.new(table, [:set, :private])
    {:ok, pid}
  end

  @impl true
  def handle_call({:read, key}, _from, state) do
    case :ets.lookup(state, key) do
      [{^key, value}] -> {:reply, {:ok, value}, state}
      [] -> {:reply, :error, state}
    end
  end

  @impl true
  def handle_call({:readall}, _from, state) do
    {:reply, {:ok, :ets.tab2list(state)}, state}
  end

  @impl true
  def handle_cast({:create, key, value}, state) do
    :ets.insert(state, {key, value})
    {:noreply, state}
  end

  def handle_cast({:update, key, value}, state) do
    test = :ets.lookup(state, key)

    if length(test) > 0 do
      :ets.insert(state, {key, value})
    end

    {:noreply, state}
  end

  def handle_cast({:delete, key}, state) do
    :ets.delete(state, key)
    {:noreply, state}
  end
end

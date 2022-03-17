defmodule Server.DynSupervisor do
  use DynamicSupervisor

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(order) do
    DynamicSupervisor.start_child(Server.DynSupervisor, {TransitionGenServ, order})
  end

  def get_child(order) do
    count = DynamicSupervisor.count_children(Server.DynSupervisor)

    pid = if count[:active] > 0 do
      find = Enum.find(DynamicSupervisor.which_children(Server.DynSupervisor), fn x -> TransitionGenServ.call(elem(x, 1))["id"] == order end)
      if find != nil do
        elem(find, 1)
      else
        nil
      end
    else
      nil
    end

    if pid == nil do
      elem(Server.DynSupervisor.start_child(order), 1)
    else
      pid
    end
  end
end

defmodule ServSupervisorTest do
  use ExUnit.Case, async: true

  setup do
    supervisor = start_supervised!(ServSupervisor)
    %{supervisor: supervisor}
  end


  test "Count children", %{supervisor: supervisor} do
    assert Supervisor.count_children(supervisor) == %{specs: 1, active: 1, supervisors: 0, workers: 1}
  end
end

defmodule Server.JsonLoaderTest do
  use ExUnit.Case, async: true

  # setup do
  #   loader = start_supervised!(Server.JsonLoader)
  #   %{loader: loader}
  # end


  test "read existing file" do
    result = Server.JsonLoader.load_to_database("","/home/vincent/Documents/Projects/KBRW/training/2021_12_30_formation/Formation/Resources/chap1/orders_dump/orders_chunk0.json")
    # assert elem(result, 0) == :ok
    # assert result == :ok
  end

  # test "read non existing file" do
  #   result = Server.JsonLoader.load_to_database("","/home/vincent/Documents/Projects/KBRW/training/2021_12_30_formation/Formation/Resources/chap1/orders_dump/orders_chunk9.json")
  #   assert elem(result, 0) == :error
  # end

end

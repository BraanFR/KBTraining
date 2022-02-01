defmodule Server.DatabaseTest do
  use ExUnit.Case, async: true

  setup do
    database = start_supervised!(Server.Database)
    %{database: database}
  end

  test "create new entry", %{database: database} do
    Server.Database.create(database, "cle", "valeur")
  end


  test "read new entry", %{database: database} do
    Server.Database.create(database, "cle", "valeur")
    assert Server.Database.read(database, "cle") == {:ok, "valeur"}
  end


  test "read non existing entry", %{database: database} do
    assert Server.Database.read(database, "cle") == :error
  end


  test "delete entry", %{database: database} do
    Server.Database.create(database, "cle", "valeur")
    assert Server.Database.read(database, "cle") == {:ok, "valeur"}

    Server.Database.delete(database, "cle")
    assert Server.Database.read(database, "cle") == :error
  end


  test "Update entry", %{database: database} do
    Server.Database.create(database, "cle", "valeur")
    assert Server.Database.read(database, "cle") == {:ok, "valeur"}

    Server.Database.update(database, "cle", "valeur2")
    assert Server.Database.read(database, "cle") == {:ok, "valeur2"}
  end


  test "Update non existing entry", %{database: database} do
    Server.Database.update(database, "cle", "valeur")
    assert Server.Database.read(database, "cle") == :error
  end
end

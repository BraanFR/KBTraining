defmodule Server.JsonLoader do

  def load_to_database(database, json_file) do
    file_read = File.read(json_file)
    parsed_file = Poison.Parser.parse!(elem(file_read, 1))

    for item <- parsed_file do
      Server.Database.create(database, item["id"], item)
    end
  end
end

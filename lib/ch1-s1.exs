# my_table = :ets.new(:table, [:table_name])
:ets.new(:table, [:table_name])

:ets.insert_new(my_table, {1, "toto"})
:ets.lookup(my_table, 1)
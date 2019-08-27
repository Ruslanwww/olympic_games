require_relative "app/data_base_execute"
require_relative "app/factories/connection_factory"

db_path = "olympic_history.db"
db = ConnectionFactory.pg
db.connect(db_path)

obj = DataBaseExecute.new(160)
obj.params_read(ARGV[1..-1])

obj.read_chart_name(ARGV.first, db)

db.connection.close

require_relative "app/data_base_execute"
require_relative "app/data_base_connection"

db_path = "olympic_history.db"
db = DataBaseConnection.new.connect(db_path)

obj = DataBaseExecute.new(160)
obj.params_read(ARGV[1..-1])

obj.read_chart_name(ARGV.first, db)

db.close

require_relative "app/parser"
require_relative "app/data_base_import"
require_relative "app/factories/connection_factory"

start_time = Time.now

csv_path = "athlete_events.csv"
db_path = "olympic_history.db"

obj = Parser.new(csv_path)
result = obj.parse_data

db = ConnectionFactory.pg
db.connect(db_path)

DataBaseImport.new.import(result, db)

db.connection.close

p Time.now - start_time

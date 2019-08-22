require 'sqlite3'

class DataBaseConnection
  def connect(db_name)
      SQLite3::Database.open db_name
  end
end

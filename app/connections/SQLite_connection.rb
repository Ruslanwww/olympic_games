require_relative "connection.rb"

class SQLiteConnection < Connection
  attr_reader :connection

  def connect(db_name)
    @connection = SQLite3::Database.open db_name
  end
  
  def execute(sql, params = nil)
    connection.execute sql, params
  end

  def values(row_count, column_count)
    arr_str = []

    arr_str << "(" + Array.new(column_count, "?").join(',') + ")"
    (arr_str * row_count).join(',')
  end

  def prepare_elements(elements)
    elements
  end

  def get_data(data)
    data
  end
end

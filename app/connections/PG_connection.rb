require_relative "connection.rb"

class PGConnection < Connection
  attr_reader :connection

  def connect(db_name)
    @connection =  PG.connect dbname: db_name
  end
  
  def execute(sql, params = nil)
    connection.exec sql, params
  end

  def values(row_count, column_count)
    arr_v = []
    arr_str = []
    (1..row_count * column_count).each{ |e| arr_v << "$#{e}" }
    
    arr_v.each_slice(column_count){ |e| arr_str << "(" + e.join(',') + ")" }
    arr_str.join(',')
  end

  def prepare_elements(elements)
    elements.flatten
  end

  def get_data(data)
    data.values
  end

  def get_param(number = 1)
    "$#{number}"
  end

  def close
    connection.close
  end
end

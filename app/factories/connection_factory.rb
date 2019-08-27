require 'sqlite3'
require 'pg'
require_relative "../connections/SQLite_connection"
require_relative "../connections/PG_connection"

class ConnectionFactory
  def self.pg
    PGConnection.new
  end

  def self.sqlite
    SQLiteConnection.new
  end
end

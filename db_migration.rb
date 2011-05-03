require 'sqlite3'

db = SQLite3::Database.new(File.expand_path(File.dirname(__FILE__)) + '/user_states.db')
db.execute("alter table user_states add column last_modified INT")
db.execute("update user_states set last_modified = ?", Time.now.to_i)
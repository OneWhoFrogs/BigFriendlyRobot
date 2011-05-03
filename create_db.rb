require 'sqlite3'

db = SQLite3::Database.new(File.expand_path(File.dirname(__FILE__)) + '/user_states.db')
db.execute("create table user_states (key INTEGER PRIMARY KEY, user TEXT, subreddit TEXT, state TEXT, id TEXT, last_modified INTEGER)")
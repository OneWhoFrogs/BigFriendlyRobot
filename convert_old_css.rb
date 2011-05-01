require 'sqlite3'
require 'ap'
require 'json'

db = SQLite3::Database.new(File.expand_path(File.dirname(__FILE__)) + '/user_states.db')

css = File.read("css/stlouis_users.css")
css.split("}").each do |user|
  parts = user.split('"')
  username = parts[1]
  town = parts[3].delete("[]").strip
  json = `curl --silent -b cookies.txt http://www.reddit.com/user/#{username}/about.json`
  id = JSON.parse(json)['data']['id']
  db.execute("insert into user_states (user, subreddit, state, id) values (:user, :subreddit, :change, :id)", :user => username, :subreddit => "stlouis", :change => town, :id => id)
  puts "Added data for #{username}"
  sleep 2
end
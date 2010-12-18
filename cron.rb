require_relative 'bot.rb'

bot = Bot.new(ENV['bfr_user'], ENV['bfr_passwd'])
puts "Logging in"
bot.login
puts "Checking messages"
bot.check_messages
puts "Updating DB"
bot.update_db
puts "Uploading new CSS"
bot.update_css
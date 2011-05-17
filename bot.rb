require 'json'
require 'curb'
require 'sqlite3'
require 'nokogiri'
require 'ap'
require 'logger'
require_relative 'subreddits.rb'

class Bot
  def initialize(user, passwd)
    abort "Please set both your username and password as environment variables ('bfr_user' and 'bfr_passwd'.)" if user.nil? or passwd.nil?
    @user, @passwd = user, passwd
    
    @subreddits = {
      "bigfriendlyrobot" => BigFriendlyRobot.new,
      "stlouis" => StLouis.new,
      "motorcycles" => Motorcycles.new,
      "autos" => Autos.new
    }
    
    @db = SQLite3::Database.new("#{path}/user_states.db")
    @logger = Logger.new("#{path}/css_bot.log")
  end
  
  def login
    @logger.info "Logging in with username: #{@user} and password: #{@passwd}"
    data = request("curl --silent -d api_type=json -d user=#{@user} -d passwd=#{@passwd} -c #{Dir.pwd}/cookies.txt http://www.reddit.com/api/login")
    # TODO: replace with cleaner code
    @modhash = data.split('"modhash": "')[1].split('", "cookie":').first
  end
  
  def reply_to_message(id, text)
    raise "Not logged in!" unless @modhash
    
    @logger.info "Replying to message #{id}."
    
    c = Curl::Easy.new("http://www.reddit.com/api/comment")
    c.enable_cookies = true
    c.cookiefile = "#{path}/cookies.txt"
    
    c.http_post(Curl::PostField.content('id', "comment_reply_#{id}"),
                  Curl::PostField.content('text', text),
                  Curl::PostField.content('thing_id', id),
                  Curl::PostField.content('renderstyle', 'html'),
                  Curl::PostField.content('uh', @modhash))
    sleep 2
  end
  
  def upload(subreddit, css)
    raise "Not logged in!" unless @modhash
    
    @logger.info "Uploading CSS to #{subreddit}"

    c = Curl::Easy.new("http://www.reddit.com/api/subreddit_stylesheet")
    c.enable_cookies = true
    c.cookiefile = "#{path}/cookies.txt"
    
    c.http_post(Curl::PostField.content('id', '#subreddit_stylesheet'),
                  Curl::PostField.content('op', 'save'),
                  Curl::PostField.content('r', subreddit),
                  Curl::PostField.content('renderstyle', 'html'),
                  Curl::PostField.file('stylesheet_contents', css),
                  Curl::PostField.content('uh', @modhash))
    sleep 2
  end
  
  def check_messages
    raise "Not logged in!" unless @modhash
    json = request("curl --silent -b #{path}/cookies.txt http://www.reddit.com/message/unread/.json")
    j = JSON.parse(json)
    messages = j['data']['children'].inject([]) do |result, message|
      message = message['data']
      hash = Hash.new
      hash = { subreddit: message['subject'].downcase, user: message['author'], change: message['body'], reply_name: message['name'] }
      result << hash
    end
    request("curl --silent -b #{path}/cookies.txt http://www.reddit.com/message/inbox/") # mark messages as read
    @messages = messages
  end
  
  def update_db
    @messages.each do |message|
      subject = message[:subreddit].split(':')
      # update local CSS if a mod messages the bot
      subreddit = @subreddits[subject.first]
      if subject.last == "css" and not subreddit.nil? and subject.length == 2
        
        moderator_html = request("curl --silent http://www.reddit.com/r/#{subreddit.name}/about/moderators")
        n = Nokogiri::HTML(moderator_html)
        moderators = n.xpath("//div[@id='moderator-table']/table/tr/td/span/a").collect { |mod| mod.text }
        
        if moderators.include?(message[:user])
          if message[:change].match(/^http:\/\/dpaste.com\/\d+\/plain\/?$/)
            @logger.info("Downloading new CSS for #{subreddit.name} from #{message[:change]}")
            downloaded_css = `curl --silent #{message[:change]}`
            File.open(subreddit.css, "w") { |f| f.write downloaded_css }
          else
            reply_to_message message[:reply_name], "To change the CSS, please send the URL for a raw file at [dpaste](http://dpaste.com)."
          end
        else
          reply_to_message message[:reply_name], "You aren't a moderator in this subreddit. Only mods can edit the CSS."
        end
      end
    end
    
    messages = @messages.delete_if do |message|
      subreddit = message[:subreddit]
      
      # unless it's a reply to one of the bot's messages
      if not message[:subreddit].split(':').last == "css" and not subreddit.index("re: ") == 0
        if @subreddits[subreddit].nil?
          reply_to_message message[:reply_name], "The subreddit you specified isn't managed by this bot."
        elsif not @subreddits[subreddit].valid?(message[:change])
          reply_to_message message[:reply_name], "Your message must be of the format:\n\n#{@subreddits[subreddit].format}"
        end
      end
      
      @subreddits[subreddit].nil? or message[:subreddit].split(':').last == "css" or not @subreddits[subreddit].valid?(message[:change])
    end
    messages.each do |message|
      # sqlite gets upset when I pass unnecessary hash values, so each one has to be explicitly defined here
      if @db.execute("select * from user_states where user = :user and subreddit = :subreddit", :user => message[:user], :subreddit => message[:subreddit]).empty?
        json = request("curl --silent -b cookies.txt http://www.reddit.com/user/#{message[:user]}/about.json")
        id = JSON.parse(json)['data']['id']
        @logger.info "Adding new record for #{message.to_s}"
        @db.execute("insert into user_states (user, subreddit, state, id, last_modified) values (:user, :subreddit, :change, :id, :current_timestamp)", :user => message[:user], :subreddit => message[:subreddit], :change => message[:change], :id => id, :current_timestamp => Time.now.to_i)
      else
        @logger.info "Updating record for #{message.to_s}"
        @db.execute("update user_states set state = :change, last_modified = :current_timestamp where user = :user and subreddit = :subreddit", :change => message[:change], :user => message[:user], :subreddit => message[:subreddit], :current_timestamp => Time.now.to_i)
      end
    end
  end
  
  def update_css
    def compress(css)
      # remove comments
      css.gsub!(/\/\*(.|\n|\t|\r)*?\*\//, '')
      # whitespace
      css.gsub!(/\n|\t|\r/, '')
      css.squeeze!(' ')
      css
    end
    @db.results_as_hash = true
    @subreddits.each do |name, reddit|
      @logger.info "Creating CSS for #{name}"
      rows = @db.execute("select * from user_states where subreddit = :subreddit", :subreddit => name)
      user_css = reddit.build_css(rows)
      css = File.open(path + '/' + reddit.css).read + "\n" + user_css
      upload(name, compress(css))
    end
    
    @db.results_as_hash = false
  end
  
  private
  
  def path
    File.expand_path(File.dirname(__FILE__))
  end
  
  def request(cmd)
    @logger.info "Making request #{cmd}"
    r = `#{cmd}`
    # obeying the API request limit here
    sleep 2
    r
  end
end

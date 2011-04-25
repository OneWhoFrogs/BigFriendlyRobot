class Subreddit
  attr_accessor :name, :regex, :css, :moderators, :format
  Banned_words = ['cheesecake', 'karaoke', 'couch']
  
  def initialize
  end
  
  def valid?(input)
    def clean?(input)
      Banned_words.each do |word|
        if input.include?(word)
          return false
        end
      end
      true
    end
    not input.match(@regex).nil? and clean?(input)
  end
  
  def build_css
  end
end

class BigFriendlyRobot < Subreddit
  def initialize
    @name = "BigFriendlyRobot"
    @css = "css/bigfriendlyrobot.css"
    @format = "a reddit username"
    @moderators = ['ExtremePopcorn', 'BigFriendlyRobot']
    @regex = /^[a-zA-Z0-9_]+$/
  end
  
  def build_css(rows)
    css = rows.inject("") do |memo, row|
      memo += ".id-t2_#{row["id"]}:before, "
    end
    css = css[0..-3]
    if css
      return css + "{content: '';background-position: -10px 10px;width: 14px}"
    else
      return ""
    end
  end
end
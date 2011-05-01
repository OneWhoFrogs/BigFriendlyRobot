class Subreddit
  attr_accessor :name, :regex, :css, :moderators, :format
  Banned_words = []
  
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
    @format = "an alphanumeric string (spaces allowed)"
    @regex = /^[a-zA-Z0-9 ]+$/
  end
  
  def build_css(rows)
    css = rows.inject("") do |memo, row|
      memo += ".id-t2_#{row["id"]}:after {content: ' #{row['state']}' !important}\n"
    end
  end
end

class StLouis < Subreddit
  def initialize
    @name = "StLouis"
    @css = "css/stlouis.css"
    @format = "An alphabetical string. Spaces, commas, periods, and apostrophes are allowed."
    @regex = /^[a-zA-Z .,']+$/
  end
  
  def build_css(rows)
    css = rows.inject("") do |memo, row|
      memo += ".id-t2_#{row["id"]}:after {color: gray; font-size: 0.75em; content: ' [#{row['state']}]' !important}\n"
    end
  end
end
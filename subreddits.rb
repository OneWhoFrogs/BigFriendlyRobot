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
    input == input.match(/^[a-zA-Z0-9\-\/' ]{0,40}$/).to_s and clean?(input)
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
    @regex = /^[a-zA-Z .,']{0,20}$/
  end
  
  def build_css(rows)
    css = rows.inject("") do |memo, row|
      state = row['state']
      memo += ".id-t2_#{row["id"]}:after {color: gray; font-size: 0.75em; content: \" [#{state}]\" !important}\n"
    end
  end
end

class Motorcycles < Subreddit
  def initialize
    @name = "Motorcycles"
    @css = "css/motorcycles.css"
    @format = "Letters, numbers, and spaces only. Text must be less than 40 characters long."
    @regex = /^[a-zA-Z0-9\-\/ ]{0,40}$/
  end
  
  def build_css(rows)
    css = rows.inject("") do |memo, row|
      state = row['state']
      memo += ".id-t2_#{row["id"]}:after {color: gray; font-size: 0.75em; content: \" #{state}\" !important}\n"
    end
  end
end

class Autos < Subreddit
  def initialize
    @name = "Autos"
    @css = "css/autos.css"
    @format = "Letters, numbers, spaces, dashes, and apostrophes only. Text must be shorter than or equal to 40 characters in length."
    @regex = /^[a-zA-Z0-9\-\/' ]{0,40}$/
  end

  def build_css(rows)
    css = rows.inject("") do |memo, row|
      state = row['state']
      memo += ".id-t2_#{row["id"]}:after {color: gray; font-size: 0.75em; content: \" [#{state}]\" !important}\n"
    end
  end
end

class Cars < Subreddit
  def initialize
    @name = "Cars"
    @css = "css/cars.css"
    @regex = /^[a-zA-Z0-9\-\/' ]{0,40}$/
    @format = "Letters, numbers, spaces, dashes, and apostrophes only. Text must be shorter than or equal to 40 characters in length."
  end

  def build_css(rows)
    css = rows.inject("") do |memo, row|
      state = row['state']
      memo += ".id-t2_#{row["id"]}:after {color: gray; font-size: 0.8em; content: \" [#{state}]\" !important}\n"
    end
  end
end

class Sailing < Subreddit
  def initialize
    @name = "Sailing"
    @css = "css/sailing.css"
    @regex = /^[a-zA-Z0-9\-\/' ]{0,40}$/
    @format = "Letters, numbers, spaces, dashes, and apostrophes only. Text must be shorter than or equal to 40 characters in length."
  end

  def build_css(rows)
    css = rows.inject("") do |memo, row|
      state = row['state']
      memo += ".id-t2_#{row["id"]}:after {color: gray; font-size: 0.8em; content: \" [#{state}]\" !important}\n"
    end
  end
end
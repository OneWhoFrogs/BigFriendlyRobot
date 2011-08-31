# When flair came out, I completely redesigned the bot. The source code here isn't currently running on BFR.

You can find a reasonably current archive here: http://dl.dropbox.com/u/4907943/BigFriendlyRobot-8-22.zip

Let me know if you'd like a more up to date version.

# BigFriendlyRobot #

BigFriendlyRobot is a reddit bot that manages user tags within subreddits.  Check out [/r/bigfriendlyrobot](http://reddit.com/r/bigfriendlyrobot).  To create a tag there, message [BigFriendlyRobot](http://www.reddit.com/message/compose/?to=BigFriendlyRobot) with the following fields:

	Subject (name of subreddit): bigfriendlyrobot
	Message (in the case of this subreddit, any alphanumeric string with spaces): is your friend
	
The bot will append "is your friend" to your username within 10 minutes' time.

# Features #

* Compresses the CSS
	* Can use the user ID instead of username ([see here](http://www.reddit.com/r/soccer/comments/dyw0p/concerning_user_crests/c13zuu2))
* Adding subreddits is _easy_ -- it takes about 7 lines of code
* Flexible tag validation system
* Mods can change the CSS through the bot ([Wiki Page](https://github.com/OneWhoFrogs/BigFriendlyRobot/wiki/Editing-the-CSS))
* Notifies users of invalid tags
* Can include only the most recently submitted tags for subreddits that are nearing the 100KB CSS file size limit.

I have hosting set up already and it's no effort to add more subreddits. Let me know if you want the bot to administrate the tags on your subreddit.
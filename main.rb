#!/usr/bin/ruby

require 'twitter'
require 'tweetstream'
require 'yaml'

ID_UN_NERV			= 116548789
ID_TENKI_JP_JISHIN	= 599969854

keys = YAML.load_file("secret.yml")["twitter"]
client = Twitter::REST::Client.new do |config|
	config.consumer_key         = keys["CONSUMER_KEY"]
	config.consumer_secret      = keys["CONSUMER_SECRET"]
	config.access_token         = keys["ACCESS_TOKEN"]
	config.access_token_secret  = keys["ACCESS_TOKEN_SECRET"]
end

TweetStream.configure do |config|
	config.consumer_key         = keys["CONSUMER_KEY"]
	config.consumer_secret      = keys["CONSUMER_SECRET"]
	config.oauth_token         = keys["ACCESS_TOKEN"]
	config.oauth_token_secret  = keys["ACCESS_TOKEN_SECRET"]
	config.auth_method = :oauth
end
stream = TweetStream::Client.new

begin
	stream.userstream{|status|
		text = status.text
		next if(text=~/^RT/)
		if status.user.id == ID_TENKI_JP_JISHIN || status.user.id == ID_UN_NERV
			puts status.user.name
			puts text
			client.retweet(status.id)
		end
 	}
 rescue => e
 	puts e.message
 	retry
 end

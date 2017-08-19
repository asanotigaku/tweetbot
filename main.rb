#!/usr/bin/ruby

require 'twitter'
require 'tweetstream'
require 'slack/incoming/webhooks'
require 'yaml'

ID_UN_NERV			= 116548789
ID_TENKI_JP_JISHIN	= 599969854

yml = YAML.load_file("secret.yml")
keys = yml["twitter"]
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

slack_url = yml["slack"]["webhook_url"]
equake = Slack::Incoming::Webhooks.new slack_url["earthquake"], channel: 'earthquake', username: 'aescbot'
volcano= Slack::Incoming::Webhooks.new slack_url["volcano"], channel: 'volcano', username: 'aescbot'

begin
	stream.userstream{|status|
		text = status.text
		next if(text=~/^RT/)
		case status.user.id
		when ID_TENKI_JP_JISHIN then
			client.retweet(status.id)
		when ID_UN_NERV then
			if text.include?("緊急地震速報")
				client.retweet status.id
				equake.post text
			elsif text.include?("噴火") || text.include?("火山速報")
				client.retweet status.id
				volcano.post text
			elsif text.include?("気象") || text.include?("天気") || text.include("注意情報")
				client.retweet status.id
			end
		end
 	}
rescue => e
	puts e.message
	retry
end

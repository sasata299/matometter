#!/usr/bin/ruby

require 'base'
gem 'twitter4r'
require 'twitter'
require 'twitter/console' # twitter.yml 使うため

client = Twitter::Client.from_config( File.expand_path(File.dirname(__FILE__)) + '/../config/twitter.yml', 'twitter' )

now_users = []
client.my(:followers).each {|f|
  user_hash = f.to_hash
  now_users << user_hash[:screen_name]
}

users =  User.find(:all).map { |user| user.name }
stored = now_users - users

stored.each do |store|
  User.create!(:name => store)
  client.status(:post, "@#{store} フォローありがとうございます。一日一回あなたの発言を適当にまとめるので楽しみにしていてくださいね♪")
end

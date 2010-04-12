#!/usr/bin/ruby

# process が複数起動することがあったので、安全の為
process = `/bin/ps aux | /bin/grep new_follower.rb | /bin/grep -v grep`.split(/\n/)
exit if process.size >= 2

$:.push(File.expand_path(File.dirname(__FILE__)))
require 'base'
gem 'twitter4r'
require 'twitter'
require 'twitter/console' # twitter.yml 使うため
require 'mechanize' 
include Utils

client = Twitter::Client.from_config( File.expand_path(File.dirname(__FILE__)) + '/../config/twitter.yml', 'twitter' )

followers = get_self_followers
followers_replace = followers.map {|f| f.gsub(/@@/, '') if f =~ /@@/}
exit if followers.empty?
exit if followers.size < (@followers_num.to_i - 5)

#client.my(:followers).each {|f|
#  user_hash = f.to_hash
#  followers << user_hash[:screen_name]
#}

users = User.find(
  :all, 
  :conditions => 'delete_flag = 0'
).map { |user| user.name }

#stored = followers - users # 新規に追加する
#deleted = users - followers_replace # delete_flagを立てる
stored = followers.select {|follow| !users.include?( follow.gsub(/@@/, '') )}
p stored
deleted = users.select {|user| !(followers.include?(user) or followers.include?("@@#{user}@@"))}
p deleted

unless deleted.empty?
  friends = get_self_friends
  exit if friends.empty?
  deleted.each do |delete|
    User.remove_and_delete_flag(client, delete, friends)
  end
end

stored.each do |store|
  User.add_and_create(client, store)
end


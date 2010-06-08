#!/usr/bin/ruby

# process が複数起動することがあったので、安全の為
process = `/bin/ps aux | /bin/grep new_follower.rb | /bin/grep -v grep`.split(/\n/)
exit if process.size >= 2

$:.push(File.expand_path(File.dirname(__FILE__)))
require 'base'
#gem 'twitter4r'
#require 'twitter'
#require 'twitter/console' # twitter.yml 使うため
require 'mechanize' 
include Utils

client = Twitter::Client.from_config( File.expand_path(File.dirname(__FILE__)) + '/../config/twitter.yml', 'twitter' )

followers = get_self_followers
followers_replace = followers.map {|f| f.gsub(/@@/, '') if f =~ /@@/}.compact!
exit if followers.empty?
exit if followers.size < (@followers_num.to_i - 5)

users = User.find(
  :all, 
  :conditions => 'delete_flag = 0'
).map { |user| user.name }

stored = followers.select {|follow| !users.include?( follow.gsub(/@@/, '') )}
deleted = users.select {|user| !(followers.include?(user) || followers.include?("@@#{user}@@"))}

unless deleted.empty?
  friends = get_self_friends
  exit if friends.empty?
  deleted.each do |delete|
    User.remove_and_delete_flag(client, delete, friends)
  end
end

stored.each do |store|
  User._create(client, store)
end

followers_replace.each do |added_user|
  User._add(client, added_user)
end

#!/usr/bin/ruby

# process が複数起動することがあったので、安全の為
process = `ps aux | grep new_follower.rb | grep -v grep`.split(/\n/)
exit if process.size >= 2

$:.push(File.expand_path(File.dirname(__FILE__)))
require 'base'
require 'mechanize' 
include Utils

access_token = MyOAuth.new

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
    User.remove_and_delete_flag(access_token, delete, friends)
  end
end

stored.each do |store|
  User._create(access_token, store)
end

followers_replace.each do |added_user|
  User._add(access_token, added_user)
end

#!/usr/bin/ruby

$:.push(File.expand_path(File.dirname(__FILE__)))
require 'base'
gem 'twitter4r'
require 'twitter'
require 'twitter/console' # twitter.yml 使うため
require 'mechanize' 
include Utils

client = Twitter::Client.from_config( File.expand_path(File.dirname(__FILE__)) + '/../config/twitter.yml', 'twitter' )

followers = get_self_followers
exit if followers.empty?
exit if followers.size < (@followers_num.to_i - 5)

#client.my(:followers).each {|f|
#  user_hash = f.to_hash
#  followers << user_hash[:screen_name]
#}

users =  User.find(
  :all, 
  :conditions => 'delete_flag = 0'
).map { |user| user.name }

stored  = followers - users # 新規に追加する
deleted = users - followers # delete_flagを立てる

stored.each do |store|
  User.add_and_create(store)
end

unless deleted.empty?
  friends = get_self_followers

  deleted.each do |delete|
    User.remove_and_delete_flag(delete)
  end
end

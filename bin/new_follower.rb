#!/usr/bin/ruby

$:.push(File.expand_path(File.dirname(__FILE__)))
require 'base'

gem 'twitter4r'
require 'twitter'
require 'twitter/console' # twitter.yml 使うため
require 'mechanize' 

def login
  agent = WWW::Mechanize.new
  agent.user_agent_alias = 'Mac FireFox'
  page = agent.get('http://twitter.com/login')
  #login_form = page.forms.first
  login_form = page.forms[1]
  login_form['session[username_or_email]'] = "matometter"
  login_form['session[password]'] = "xxxxxxxx"
  home_page = agent.submit(login_form)
  agent
end

def get_self_followers
  agent = login
  user_followers_page = agent.get("http://twitter.com/followers")
  followers_info = (user_followers_page/"span#follower_count").inner_text
  followers_num = followers_info.to_i
  #p followers_num
  
  follower_page = nil
  page_id = nil
  now_follow = []

  loop do
    if page_id
      follower_page = agent.get("http://twitter.com/followers?page=#{page_id}")
    else
      follower_page = agent.get("http://twitter.com/followers")
    end

    followers = follower_page/"div#follow"/"span.'label screenname'"/"a"
    followers.each do |follow|
      now_follow << follow.inner_text
    end
    if link_array = follower_page.links.select {|link| link.href =~ /page/}
      /\?page=(\d+)/ =~ link_array[0].href rescue break
      page_id = $1.to_i
    else
      break
    end
  end
  
  return now_follow
end

client = Twitter::Client.from_config( File.expand_path(File.dirname(__FILE__)) + '/../config/twitter.yml', 'twitter' )

followers = []
followers = get_self_followers
#client.my(:followers).each {|f|
#  user_hash = f.to_hash
#  followers << user_hash[:screen_name]
#}

users =  User.find(:all, :conditions => 'delete_flag = 0').map { |user| user.name }

stored  = followers - users # 新規に追加する
deleted = users - followers # delete_flagを立てる

stored.each do |store|
  User.create!(:name => store)
  #client.status(:post, "@#{store} フォローありがとうございます。一日一回あなたの発言を適当にまとめるので楽しみにしていてくださいね♪")
end

deleted.each do |delete|
  delete_user = User.find_by_name(delete)
  delete_user.delete_flag = 1
  delete_user.save!
end


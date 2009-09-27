#!/usr/bin/ruby

$:.push(File.expand_path(File.dirname(__FILE__)))
require 'base'

gem 'twitter4r'
require 'twitter'
require 'twitter/console' # twitter.yml 使うため
require 'mechanize' 

def login
  config = YAML.load_file('/var/www/matometter/config/twitter.yml')
  login = config['twitter']['login']
  password = config['twitter']['password']

  agent = WWW::Mechanize.new
  agent.user_agent_alias = 'Mac FireFox'
  page = agent.get('http://twitter.com/login')
  #login_form = page.forms.first
  login_form = page.forms[1]
  login_form['session[username_or_email]'] = login
  login_form['session[password]'] = password
  home_page = agent.submit(login_form)
  agent
end

def get_self_followers
  agent = login
  
  # フォロー数を取得してた部分。今は使ってない
  #user_followers_page = agent.get("http://twitter.com/followers")
  #followers_num = (user_followers_page/"span#follower_count").inner_text.to_i

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
      next if follow.inner_text =~ /キャンセル/
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

def get_self_friends
  agent = login
  
  follower_page = nil
  page_id = nil
  now_friend = []

  loop do
    if page_id
      follower_page = agent.get("http://twitter.com/following?page=#{page_id}")
    else
      follower_page = agent.get("http://twitter.com/following")
    end

    followers = follower_page/"div#follow"/"span.'label screenname'"/"a"
    followers.each do |follow|
      now_friend << follow.inner_text
    end
    if link_array = follower_page.links.select {|link| link.href =~ /page/}
      /\?page=(\d+)/ =~ link_array[0].href rescue break
      page_id = $1.to_i
    else
      break
    end
  end
  
  return now_friend
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
  client.status(:post, "@#{store} フォローありがとうございます。一日一回くらいあなたの発言を適当にまとめるのでお楽しみに!!")
  client.friend(:add, store)
  User.create!(:name => store)
end

friends = []
friends = get_self_followers
deleted.each do |delete|
  client.friend(:remove, delete) if friends.include?(delete)
  delete_user = User.find_by_name(delete)
  delete_user.delete_flag = 1
  delete_user.save!
end


#!/usr/bin/ruby

require 'base'
gem 'twitter4r'
require 'twitter'
require 'twitter/console' # twitter.yml 使うため

#ActiveRecord::Base.logger=Logger.new(STDOUT)

client = Twitter::Client.from_config( File.expand_path(File.dirname(__FILE__)) + '/../config/twitter.yml', 'twitter' )

users = User.find(:all).map { |user| {:user_id => user.id, :user_name => user.name} }
users.each do |user|
  reply_body = Generater.generate_sentence(user[:user_id])
  client.status(:post, "@#{user[:user_name]} #{reply_body}")
  Generater.create(
    :user_id => user[:user_id],
    :body    => reply_body
  )
end


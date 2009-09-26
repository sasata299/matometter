#!/usr/bin/ruby

$:.push(File.expand_path(File.dirname(__FILE__)))
require 'base'

gem 'twitter4r'
require 'twitter'
require 'twitter/console' # twitter.yml 使うため

#ActiveRecord::Base.logger=Logger.new(STDOUT)

client = Twitter::Client.from_config( File.expand_path(File.dirname(__FILE__)) + '/../config/twitter.yml', 'twitter' )

users = {}
now_id = 1
if Time.now.hour != 15
  if File.exist?('/var/www/matometter/now_id')
    File.open('/var/www/matometter/now_id') {|f|
      now_id = f.read.chomp.to_i
    }
  else
    exit
  end
end

users = User.find(
  :all, 
  :limit => 100,
  :conditions => [ 'id >= ? and delete_flag = 0', now_id ]
).map { |user| {:user_id => user.id, :user_name => user.name} }

users.each do |user|
  reply_body = Generater.generate_sentence(user[:user_id])
  next if reply_body.nil?
  begin 
    client.status(:post, "@#{user[:user_name]} #{reply_body}")
    Generater.create(
      :user_id => user[:user_id],
      :body    => reply_body
    )
  rescue Twitter::RESTError => e    
    File.open('/var/www/matometter/now_id', 'w') {|f|
      f.puts user[:user_id]
    }
  end
end

if users.size == 100
  File.open('/var/www/matometter/now_id', 'w') {|f|
    f.puts user[:user_id]
  }
else
  File.delete('/var/www/matometter/now_id')
end

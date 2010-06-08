#!/usr/bin/ruby

CONSUMER_KEY        = 'SECRET'
CONSUMER_SECRET     = 'SECRET'
ACCESS_TOKEN        = 'SECRET'
ACCESS_TOKEN_SECRET = 'SECRET'

SIZE = 60

# process が複数起動することがあったので、安全の為
process = `/bin/ps aux | /bin/grep generate.rb | /bin/grep -v grep`.split(/\n/)
exit if process.size >= 2

$:.push(File.expand_path(File.dirname(__FILE__)))
require 'base'

#gem 'twitter4r'
#require 'twitter'
#require 'twitter/console' # twitter.yml 使うため

#ActiveRecord::Base.logger=Logger.new(STDOUT)

#client = Twitter::Client.from_config( File.expand_path(File.dirname(__FILE__)) + '/../config/twitter.yml', 'twitter' )
consumer = OAuth::Consumer.new(
  CONSUMER_KEY,
  CONSUMER_SECRET,
  :site => 'http://twitter.com'
)
access_token = OAuth::AccessToken.new(
  consumer,
  ACCESS_TOKEN,
  ACCESS_TOKEN_SECRET
)

users = {}
now_id = 1
if File.exist?('/var/www/matometter/now_id')
  File.open('/var/www/matometter/now_id') {|f|
    now_id = f.read.chomp.to_i
  }
else
  exit unless Time.now.hour.to_s =~ /^(14|15|16|17)$/
end

users = User.find(
  :all, 
  :conditions => [ 'id >= ? and delete_flag = 0', now_id ],
  :limit      => SIZE
).map { |user| {:user_id => user.id, :user_name => user.name} }

now_process = 0
users.each do |user|
  now_process = user[:user_id]

  reply_body = Generater.generate_sentence(user[:user_id])
  next if reply_body.nil?
  reply_body.gsub!(/"/, '') # "があるとPOST時に変なところで閉じられちゃうため

  begin 
    #client.status(:post, "@#{user[:user_name]} #{reply_body}")
    access_token.post(
      'http://twitter.com/statuses/update.json',
      'status' => "@#{user[:user_name]} #{reply_body}"
    )
    Generater.create(
      :user_id => user[:user_id],
      :body    => reply_body
    )
  rescue Twitter::RESTError => e
    p e.message
    sleep 60
    num = 0 if num.nil?
    num += 1
    
    File.open('/var/www/matometter/now_id', 'w') {|f|
      f.puts now_process
    }

    exit if num >= 2
    
    retry
  rescue => e    
    p e.message
    File.open('/var/www/matometter/now_id', 'w') {|f|
      f.puts now_process
    }
    exit
  end
end

if users.size == SIZE
  File.open('/var/www/matometter/now_id', 'w') {|f|
    f.puts(now_process + 1)
  }
else
  File.delete('/var/www/matometter/now_id')
end


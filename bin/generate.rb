#!/usr/bin/ruby

SIZE = 50

# process が複数起動することがあったので、安全の為
process = `ps aux | grep generate.rb | grep -v grep`.split(/\n/)
exit if process.size >= 2

$:.push(File.expand_path(File.dirname(__FILE__)))
require 'base'

access_token = MyOAuth.new

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


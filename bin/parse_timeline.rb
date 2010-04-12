#!/usr/bin/ruby

SIZE = 50

# process が複数起動することがあったので、安全の為
process = `/bin/ps aux | /bin/grep parse_timeline.rb | /bin/grep -v grep`.split(/\n/)
exit if process.size >= 2

$:.push(File.expand_path(File.dirname(__FILE__)))
require 'base'

#ActiveRecord::Base.logger=Logger.new(STDOUT)

parse_id = 1
if File.exist?('/var/www/matometter/now_parse_id')
  File.open('/var/www/matometter/now_parse_id') {|f|
    parse_id = f.read.chomp.to_i
  }
end

users = User.find(
  :all, 
  :conditions => [ 'delete_flag = 0 AND id >= ?', parse_id ],
  :limit      => SIZE
).map { |user| {:user_id => user.id, :user_name => user.name} }

users.each do |user|
  parse_id = user[:user_id]

  remarks = Remark.scrape_timeline(user[:user_name], user[:user_id])
  next if remarks.nil?

  remarks.each do |remark|
    if @remark = Remark.find_by_remark(remark[:remark])
      @remark.wakati = remark[:wakati]
      @remark.save
    else
      begin
        Remark.create!(remark)

        remark_id = Remark.find_by_remark(remark[:remark]).id

        classify = Classify.parse(remark[:remark])
        classify.each do |cl|
          Classify.create!(
            :remark_id => remark_id,
            :word      => cl
          )
        end
      rescue => e
        p e.message
        next
      end
    end
  end
end

if users.size == SIZE
  parse_id += 1
  File.open('/var/www/matometter/now_parse_id', 'w') {|f|
    f.puts parse_id
  }
else
  File.delete('/var/www/matometter/now_parse_id')
end

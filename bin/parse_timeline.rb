#!/usr/bin/ruby

$:.push(File.expand_path(File.dirname(__FILE__)))
require 'base'

#ActiveRecord::Base.logger=Logger.new(STDOUT)

users = User.find(
  :all, 
  :conditions => 'delete_flag = 0'
).map { |user| {:user_id => user.id, :user_name => user.name} }

users.each do |user|
  remarks = Remark.scrape_timeline(user[:user_name], user[:user_id])
  next if remarks.nil?

  remarks.each do |remark|
    if @remark = Remark.find_by_remark(remark[:remark])
      @remark.wakati = remark[:wakati]
      @remark.save!
    else
      Remark.create!(remark)

      remark_id = Remark.find_by_remark(remark[:remark]).id

      classify = Classify.parse(remark[:remark])
      classify.each do |cl|
        Classify.create!(
          :remark_id => remark_id,
          :word      => cl
        )
      end
    end
  end
end


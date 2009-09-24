#!/usr/bin/ruby

$:.push(File.expand_path(File.dirname(__FILE__)))
require 'base'

ActiveRecord::Base.logger=Logger.new(STDOUT)

users = User.find(:all, :conditions => 'delete_flag = 0').map { |user| {:user_id => user.id, :user_name => user.name} }
users.each do |user|
  remarks = Remark.scrape_timeline(user[:user_name])
  next if remarks.nil?

  remarks.each do |remark|
    if @remark = Remark.find_by_remark(remark[:remark])
      @remark.wakati = remark[:wakati]
      @remark.save!
    else
      Remark.create!(remark)
    end
  end
end

users.each do |user|
  remarks = Remark.find(
    :all,
    :conditions => [ 'user_id = ? AND updated_at >= ?', user[:user_id], 1.hour.ago ],
    :limit      => 20,
    :order      => 'updated_at DESC'
  )
  
  remarks.each do |rw|
    classify = Classify.parse(rw.remark)
    classify.each do |cl|
      Classify.create!(
        :remark_id => rw.id,
        :word      => cl
      )
    end
  end
end


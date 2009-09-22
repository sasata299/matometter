class TopController < ApplicationController
  def index
    render :text => "TOP"
  end

  def create
    remarks = Remark.scrape_timeline(params[:id])
    remarks.each do |remark|
      @remark = Remark.new(remark)
      @remark.save!
    end

    render :text => "store"
  end

  def classify
    remarks = Remark.find(
      :all, 
      :conditions => ['user_id = ? and remark like "%おばあちゃん%"', params[:id]],
      :limit      => 20,
      :order      => 'updated_at DESC'
    )
    remarks.each do |rw|
      classify = Classify.parse(rw.remark)
      pp classify
      exit

      classify.each do |cl|
        @classify = Classify.new(
          :user_id => rw.user_id,
          :word    => cl
        )
        @classify.save!
      end
    end

    render :text => "store"
  end
  
  def generate
    @sentence = Generater.generate_sentence(1)
  end

  def hoge
    @hoge = Remark.hoge('そういえば今日Suica忘れてちょうひさしぶりに切符買った。Suicaのありがたみが身にしみる')
    render :text => 'gagag'
  end
end

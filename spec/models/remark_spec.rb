require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Remark do
  before do
    @valid_attributes = {
      :user_id => 1,
      :remark  => '私はカープが好きです',
      :wakati  => '私 は カープ が 好き です'
    }
  end

  it "データが正しく保存できること" do
    Remark.create!(@valid_attributes)
  end
end

describe Remark, "#scrape_timeline" do
  fixtures :users

  it "最新20件のタイムラインが取得できること" do
    remarks = Remark.scrape_timeline('sasata299')
    remarks.size.should == 20
  end
end

describe Remark, "#wakatigaki" do
  before do
    @remark = [ '日本語の勉強をする', '今日は良い天気です' ]
    @remark_wakati = [ '日本語 の 勉強 を する ', '今日 は 良い 天気 です ']
  end

  it "正しくわかち書きされること" do
    @remark.size.times do |num|
      Remark.wakatigaki(@remark[num]).delete("\n").should == @remark_wakati[num]
    end
  end
end


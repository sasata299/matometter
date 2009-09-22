require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Classify do
  describe "remark_id が指定されている場合" do
    before do
      @valid_attributes = {
        :remark_id => 1,
        :word      => '今日',
      }
    end

    it "データが正しく保存できること" do
      Classify.create!(@valid_attributes)
    end
  end

  describe "remark_id が nil の場合" do
    before do
      @valid_attributes = {
        :word      => '今日',
        :word_type => '名詞',
        :remark_id => nil,
      }
    end

    it "データの保存に失敗すること" do
      pending "MySQL 側で NOT NULL 付けるとテスト失敗する？"
      @classify = Classify.new(@valid_attributes)
      @classify.save.should be_nil
    end
  end
end

describe Classify, "#parse" do
  before do
    @remark = %W/
日本語を解析する
そういえば今日Suica忘れてちょうひさしぶりに切符買った。Suicaのありがたみが身にしみる...
後輩がテレビ局で働いてた。びっくり。
おじいちゃんとおばあちゃんの集団に囲まれたなう
/

    @remark_wakati = {}
    @remark_wakati[0] = %W/日本語を 解析する。/
    @remark_wakati[1] = %W/そういえば 今日Suica忘れて ちょうひさしぶりに 切符買った。 Suicaの ありがたみが 身に しみる.../
    @remark_wakati[2] = %W/後輩が テレビ局で 働いてた。 びっくり/
    @remark_wakati[3] = ['おじいちゃんと', 'おばあちゃんの', '集団に', '囲まれた。', 'なう ']
  end

  it "正しく単語の分類が行われること" do
    @remark.size.times do |num|
      Classify.parse(@remark[num]).should == @remark_wakati[num]
    end
  end
end


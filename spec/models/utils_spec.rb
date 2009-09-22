describe Utils, "#remove_noise" do
  before do
    @remark_with_noise = [ '@hoge こんにちわ', 'RT @fuga 今日は暑いらしい', 'なにこれ http://foo.bar', '@sasasa テスト RT @gagaga どらえもん？ http://google.co.jp' ]
    @remark = [ 'こんにちわ', '今日は暑いらしい', 'なにこれ ', 'テスト どらえもん？ ' ]
  end

  it "発言からノイズが除去されること" do
    @remark_with_noise.size.times do |i|
      Utils.remove_noise(@remark_with_noise[i]).should == @remark[i] 
    end
  end
end

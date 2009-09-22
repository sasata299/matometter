require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Generater do
  before do
    @valid_attributes = {
      :user_id => 1,
      :body    => '今日はSuica買ってなう'    
    }
  end

  it "データが正しく保存できること" do
    Generater.create!(@valid_attributes)
  end
end

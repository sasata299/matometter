require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Dictionary do
  before do
    @valid_attributes = {
      :word      => 'そういえば', 
      :word_type => '副詞'
    }
  end

  it "データが正しく保存できること" do
    Dictionary.create!(@valid_attributes)
  end
end

require 'spec_helper'

describe Wikipedia::VandalismDetection::Diff do

  it "can deal with invalid byte sequences" do
    text = "text \255".force_encoding('UTF-8')
    expect { Wikipedia::VandalismDetection::Diff.new("#{text} a", "#{text} b") }.not_to raise_error
  end

  before do
    @old_text =  Wikipedia::VandalismDetection::Text.new "hello\nworld\nmy name is Luke\n"
    @new_text =  Wikipedia::VandalismDetection::Text.new "world\nhello\nmy name is Mr. Skywalker\n"
    @diff =  Wikipedia::VandalismDetection::Diff.new(@old_text, @new_text)
  end

  describe "getting the inserted and removed words" do

    it "can return the added words as array" do
      inserted_words = @diff.inserted_words
      inserted_words.should be_an Array
      inserted_words.count.should == 3
    end

    it "can return the removed words as array" do
      removed_words = @diff.removed_words
      removed_words.should be_an Array
      removed_words.count.should == 2
    end

    it "returns the right inserted words" do
      @diff.inserted_words.should == ['hello', 'Mr.', 'Skywalker']
    end

    it "returns the right removed words" do
      @diff.removed_words.should == ['hello', 'Luke']
    end
  end
end
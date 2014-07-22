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

      expect(inserted_words).to be_an Array
      expect(inserted_words.count).to eq 3
    end

    it "can return the removed words as array" do
      removed_words = @diff.removed_words

      expect(removed_words).to be_an Array
      expect(removed_words.count).to eq 2
    end

    it "returns the right inserted words" do
      expect(@diff.inserted_words).to eq ['hello', 'Mr.', 'Skywalker']
    end

    it "returns the right removed words" do
      expect(@diff.removed_words).to eq ['hello', 'Luke']
    end
  end
end
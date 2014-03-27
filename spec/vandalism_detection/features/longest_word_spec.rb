require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::LongestWord do

  before do
    @feature = Wikipedia::VandalismDetection::Features::LongestWord.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the length of the edit's new revisions text's longest word" do
      text = Wikipedia::VandalismDetection::Text.new "1 22 33 a2c4e 4444 55555\n\n===head===\nfffff"
      edit = build :edit, new_revision: build(:new_revision, text: text)

      @feature.calculate(edit).should == 5
    end

    it "returns 0 on emtpy clean text" do
      text = Wikipedia::VandalismDetection::Text.new "{{speedy deletion}}"
      edit = build :edit, new_revision: build(:new_revision, text: text)

      @feature.calculate(edit).should == 0
    end
  end
end
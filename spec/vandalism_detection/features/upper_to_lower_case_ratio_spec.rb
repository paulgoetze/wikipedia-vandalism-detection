require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::UpperToLowerCaseRatio do

  before do
    @feature = Wikipedia::VandalismDetection::Features::UpperToLowerCaseRatio.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the uppercase to lowercase letters ratio of the edit's new revision inserted text" do
      old_text = Wikipedia::VandalismDetection::Text.new('text')
      new_text = Wikipedia::VandalismDetection::Text.new 'text [[1aA 4B6 8Cd ef]]' # 3 uppercase letters, 4 lowercase letters

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 3.0 / 4.0
    end

    it "returns 0.0 if no text inserted" do
      old_text = Wikipedia::VandalismDetection::Text.new("deletion text")
      new_text = Wikipedia::VandalismDetection::Text.new("text")

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 0.0
    end

    it "returns 0.0 if no uppercase letters are in inserted" do
      old_text = Wikipedia::VandalismDetection::Text.new("text")
      new_text = Wikipedia::VandalismDetection::Text.new("text insertion")

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 0.0
    end
  end
end
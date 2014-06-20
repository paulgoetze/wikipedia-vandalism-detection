require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::DigitRatio do

  before do
    @feature = Wikipedia::VandalismDetection::Features::DigitRatio.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the digit to all letters ratio of the edit's new revision inserted text" do
      old_text = Wikipedia::VandalismDetection::Text.new('text1')
      new_text = Wikipedia::VandalismDetection::Text.new 'text1 [[1A4 B6 8Cd]]' # 4 digit letters of total 8 letters

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 4.0 / 8.0
    end

    it "returns 0.0 if no text inserted" do
      old_text = Wikipedia::VandalismDetection::Text.new("deletion text")
      new_text = Wikipedia::VandalismDetection::Text.new("text")

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 0.0
    end

    it "returns 0.0 if no digits are in inserted" do
      old_text = Wikipedia::VandalismDetection::Text.new("text")
      new_text = Wikipedia::VandalismDetection::Text.new("text insertion")

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 0.0
    end
  end
end
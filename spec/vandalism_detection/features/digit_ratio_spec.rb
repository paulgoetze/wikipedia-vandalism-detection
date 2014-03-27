require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::DigitRatio do

  before do
    @feature = Wikipedia::VandalismDetection::Features::DigitRatio.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the digit to all letters ratio of the edit's new revision text" do
      text = Wikipedia::VandalismDetection::Text.new '1A4 B6 8Cd' # 3 digit letters of total 8 letters
      new_revision = build(:new_revision, text: text)
      old_revision = build(:old_revision, text: "")
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == (1.0 + 4) / (1.0 + 8)
    end

    it "returns 1.0 on emtpy clean text revisions" do
      text = Wikipedia::VandalismDetection::Text.new ""

      old_revision = build(:old_revision, text: text)
      new_revision = build(:new_revision, text: text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 1.0
    end
  end
end
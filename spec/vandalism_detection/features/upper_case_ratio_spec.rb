require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::UpperCaseRatio do

  before do
    @feature = Wikipedia::VandalismDetection::Features::UpperCaseRatio.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the uppercase to all letters ratio of the edit's new revision text" do
      text = Wikipedia::VandalismDetection::Text.new '1A 4B6 8Cd' # 3 uppercase letters of total 4 letters
      new_revision = build(:new_revision, text: text)
      edit = build(:edit, new_revision: new_revision)

      @feature.calculate(edit).should == 0.8
    end

    it "returns 1.0 on emtpy clean text revisions" do
      text = Wikipedia::VandalismDetection::Text.new "{{speedy deletion}}"

      old_revision = build(:old_revision, text: text)
      new_revision = build(:new_revision, text: text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 1.0
    end
  end
end
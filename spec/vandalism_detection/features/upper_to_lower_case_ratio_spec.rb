require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::UpperToLowerCaseRatio do

  before do
    @feature = Wikipedia::VandalismDetection::Features::UpperToLowerCaseRatio.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the uppercase to lowercase letters ratio of the edit's new revision text" do
      text = Wikipedia::VandalismDetection::Text.new '1aA 4B6 8Cd ef' # 3 uppercase letters,  4 lowercase letters
      new_revision = build(:new_revision, text: text)
      edit = build(:edit, new_revision: new_revision)

      @feature.calculate(edit).should == (1.0 + 3) / (1.0 + 4)
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
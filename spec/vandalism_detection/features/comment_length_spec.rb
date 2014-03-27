require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::CommentLength do

  before do
    @feature = Wikipedia::VandalismDetection::Features::CommentLength.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the length of the edit's new revisions comment" do
      comment = Wikipedia::VandalismDetection::Text.new "1 34567 9"
      edit = build :edit, new_revision: build(:new_revision, comment: comment)

      @feature.calculate(edit).should == 9
    end

    it "returns 0 on emtpy clean text" do
      text = Wikipedia::VandalismDetection::Text.new "{{speedy deletion}}"
      edit = build :edit, new_revision: build(:new_revision, text: text)

      @feature.calculate(edit).should == 0
    end
  end
end
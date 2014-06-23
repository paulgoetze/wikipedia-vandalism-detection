require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RevisionsCharacterDistribution do

  before do
    @feature = Wikipedia::VandalismDetection::Features::RevisionsCharacterDistribution.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the Kullback-Leibler Divergence of the inserted text's character distribution" do
      old_text = Wikipedia::VandalismDetection::Text.new('old text old text is standing here')
      new_text = Wikipedia::VandalismDetection::Text.new 'old text [[new inserted text]] given dero 9'

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 0.6312751553366259
    end

    it "returns missing value if new revision text is empty" do
      old_text = Wikipedia::VandalismDetection::Text.new("old text")
      new_text = Wikipedia::VandalismDetection::Text.new("")

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == Wikipedia::VandalismDetection::Features::MISSING_VALUE
    end

    it "returns missing value if old revision text is empty" do
      old_text = Wikipedia::VandalismDetection::Text.new("")
      new_text = Wikipedia::VandalismDetection::Text.new("new text")

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == Wikipedia::VandalismDetection::Features::MISSING_VALUE
    end
  end
end
require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RemovedPronounFrequency do

  before do
    @feature = Wikipedia::VandalismDetection::Features::RemovedPronounFrequency.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::FrequencyBase }

  describe "#calculate" do

    it "returns the number of removed pronouns relative to all removed words count" do
      # total 12 words, 7 pronouns
      old_text = Wikipedia::VandalismDetection::Text.new "Your old. I was you if You was Me and we are ourselves us."
      new_text = Wikipedia::VandalismDetection::Text.new 'Your old.'

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 7.0 / 12.0
    end

    it "returns 0.0 on emtpy removed clean text revisions" do
      old_text = Wikipedia::VandalismDetection::Text.new "Your old. {{speedy deletion}}"
      new_text = Wikipedia::VandalismDetection::Text.new 'Your old. My inserted.'

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 0.0
    end
  end
end
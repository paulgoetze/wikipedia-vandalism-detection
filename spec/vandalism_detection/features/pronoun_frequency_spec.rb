require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::PronounFrequency do

  before do
    @feature = Wikipedia::VandalismDetection::Features::PronounFrequency.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::FrequencyBase }

  describe "#calculate" do

    it "returns the number of pronouns relative to all words count" do
      # total 12 words, 7 pronouns
      old_text = Wikipedia::VandalismDetection::Text.new 'Your old.'
      new_text = Wikipedia::VandalismDetection::Text.new "Your old. I was you if You was Me and we are ourselves us."

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 7.0/12.0
    end

    it "returns 0.0 on emtpy clean text revisions" do
      old_text = Wikipedia::VandalismDetection::Text.new 'Your old.'
      new_text = Wikipedia::VandalismDetection::Text.new "Your old. {{speedy deletion}}"

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 0.0
    end
  end
end
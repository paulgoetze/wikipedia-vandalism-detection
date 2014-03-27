require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::TermFrequency do

  before do
    @feature = Wikipedia::VandalismDetection::Features::TermFrequency.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::FrequencyBase }

  describe "#calculate" do

    it "returns the average relative frequency of inserted words in the new revision" do
      # removed [you, I], added [you, you, you, we]
      # for [you, we] compute frequency in old_text and average for all words
      # here: [you] is 6x in new text, [we] is 3x in new text of total 10 words
      # avrg = (6/10 + 3/10)/2
      old_text = Wikipedia::VandalismDetection::Text.new "we\nwe\nyou\nyou\nyou\nI\nyou\nI\n"
      new_text = Wikipedia::VandalismDetection::Text.new "we\nwe\nyou\nyou\nI\nyou\n''(you''\nyou\nyou\n[[we]])\n"

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == ((6.0/10.0) + (3.0/10.0)) / 2.0
    end

    it "returns 0.0 on emtpy clean text revisions" do
      text = Wikipedia::VandalismDetection::Text.new "{{speedy deletion}}"

      old_revision = build(:old_revision, text: text)
      new_revision = build(:new_revision, text: text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 0.0
    end
  end
end

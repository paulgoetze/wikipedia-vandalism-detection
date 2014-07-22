require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::EmoticonsFrequency do

  before do
    @feature = Wikipedia::VandalismDetection::Features::EmoticonsFrequency.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the number of emoticons relative to all words count" do
      # total 10 words, 3 emoticons
      old_text = Wikipedia::VandalismDetection::Text.new 'Old :-).'
      new_text = Wikipedia::VandalismDetection::Text.new "Old :-). ;) you do love icons and emoticons? :D :P, yeah."

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 3.0 / 10.0
    end

    it "returns 0.0 on emtpy clean text revisions" do
      old_text = Wikipedia::VandalismDetection::Text.new 'Old :-).'
      new_text = Wikipedia::VandalismDetection::Text.new "Old :-). {{speedy deletion}}"

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 0.0
    end
  end
end
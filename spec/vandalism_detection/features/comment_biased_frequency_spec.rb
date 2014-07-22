require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::CommentBiasedFrequency do

  before do
    @feature = Wikipedia::VandalismDetection::Features::CommentBiasedFrequency.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::FrequencyBase }

  describe "#calculate" do

    it "returns the number of biased words in comment relative to all words count" do
      # total 10 words, 3 biased
      comment = Wikipedia::VandalismDetection::Text.new "It's Great man, this is amazing, really a classic."

      old_revision = build(:old_revision)
      new_revision = build(:new_revision, comment: comment)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 4.0 / 9.0
    end

    it "returns 0.0 on emtpy clean text comment" do
      comment = Wikipedia::VandalismDetection::Text.new "{{speedy deletion}}"

      old_revision = build(:old_revision)
      new_revision = build(:new_revision, comment: comment)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      expect(@feature.calculate(edit)).to eq 0.0
    end
  end
end
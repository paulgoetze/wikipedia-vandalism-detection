require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::CommentPronounFrequency do

  before do
    @feature = Wikipedia::VandalismDetection::Features::CommentPronounFrequency.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::FrequencyBase }

  describe "#calculate" do

    it "returns the number of pronouns in comment relative to all words count" do
      # total 12 words, 7 pronouns
      comment = Wikipedia::VandalismDetection::Text.new 'I was you if You was Me and we are ourselves us'

      old_revision = build(:old_revision)
      new_revision = build(:new_revision, comment: comment)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 7.0 / 12.0
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
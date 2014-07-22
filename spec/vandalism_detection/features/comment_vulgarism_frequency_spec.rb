require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::CommentVulgarismFrequency do

  before do
    @feature = Wikipedia::VandalismDetection::Features::CommentVulgarismFrequency.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::FrequencyBase }

  describe "#calculate" do

    it "returns the number of vulgarism words in comment relative to all words count" do
      # total 7 words, 2 vulgarism
      comment = Wikipedia::VandalismDetection::Text.new "Fuck you bitch. This is my change!"

      old_revision = build(:old_revision)
      new_revision = build(:new_revision, comment: comment)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 2.0 / 7.0
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
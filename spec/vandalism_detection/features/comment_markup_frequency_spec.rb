require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::CommentMarkupFrequency do

  before do
    @feature = Wikipedia::VandalismDetection::Features::CommentMarkupFrequency.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the number of markup words in comment relative to all words count" do
      # total 7 words, 3 markup
      comment = Wikipedia::VandalismDetection::Text.new '[[Content]] is not always {{simple}} to [[produce]]'

      old_revision = build(:old_revision)
      new_revision = build(:new_revision, comment: comment)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 3.0 / 7.0
    end

    it "returns 0.0 on emtpy text comment" do
      comment = Wikipedia::VandalismDetection::Text.new ""

      old_revision = build(:old_revision)
      new_revision = build(:new_revision, comment: comment)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      expect(@feature.calculate(edit)).to eq 0.0
    end
  end
end
require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::ArticleSize do

  before do
    @feature = Wikipedia::VandalismDetection::Features::ArticleSize.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the size of the edit's new revisions" do
      old_revision_text = Wikipedia::VandalismDetection::Text.new '123'
      new_revision_text = Wikipedia::VandalismDetection::Text.new '123 456789' # size 10 (with spaces)

      old_revision = build(:old_revision, text: old_revision_text)
      new_revision = build(:new_revision, text: new_revision_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 10
    end

    it "returns 0 if the edit's new revisions is empty" do
      old_revision_text = Wikipedia::VandalismDetection::Text.new '123'
      new_revision_text = Wikipedia::VandalismDetection::Text.new '' # size 0

      old_revision = build(:old_revision, text: old_revision_text)
      new_revision = build(:new_revision, text: new_revision_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 0
    end
  end
end
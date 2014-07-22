require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::SizeRatio do

  before do
    @feature = Wikipedia::VandalismDetection::Features::SizeRatio.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the ratio of the edit's revisions text sizes" do
      old_revision_text = Wikipedia::VandalismDetection::Text.new '123456789' # length 9
      new_revision_text = Wikipedia::VandalismDetection::Text.new '123' # length 3

      old_revision = build(:old_revision, text: old_revision_text)
      new_revision = build(:new_revision, text: new_revision_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 9.0 / (9.0 + 3.0)
    end

    it "returns 1.0 on emtpy new text revisions" do
      old_text = Wikipedia::VandalismDetection::Text.new "sample text"
      new_text = Wikipedia::VandalismDetection::Text.new ""

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      expect(@feature.calculate(edit)).to eq 1.0
    end

    it "returns 0.0 on emtpy old text revisions" do
      old_text = Wikipedia::VandalismDetection::Text.new ""
      new_text = Wikipedia::VandalismDetection::Text.new "sample text"

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      expect(@feature.calculate(edit)).to eq 0.0
    end

    it "returns 0.5 on emtpy both text revisions" do
      old_text = Wikipedia::VandalismDetection::Text.new ""
      new_text = Wikipedia::VandalismDetection::Text.new ""

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      expect(@feature.calculate(edit)).to eq 0.5
    end
  end
end
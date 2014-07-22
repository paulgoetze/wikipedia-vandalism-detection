require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::ReplacementSimilarity do

  before do
    @feature = Wikipedia::VandalismDetection::Features::ReplacementSimilarity.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns similarity of the deleted text to inserted in exchange" do
      old_text = Wikipedia::VandalismDetection::Text.new "this is Mr. Dixon"
      new_text = Wikipedia::VandalismDetection::Text.new "this is Mr. Dicksonx"

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)

      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 0.8133333333333332
    end

    it "returns 0 on empty old revisions text" do
      old_revision = build(:old_revision, text: "")
      new_revision = build(:new_revision, text: "{{speedy deletion}}")

      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 0
    end


    it "returns 0 on empty new revisions text" do
      old_revision = build(:old_revision, text: "{{speedy deletion}}")
      new_revision = build(:new_revision, text: "")

      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 0
    end
  end
end
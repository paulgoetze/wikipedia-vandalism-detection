require 'spec_helper'

describe  Wikipedia::VandalismDetection::Features::AllWordlistsImpact do

  before do
    @feature = Wikipedia::VandalismDetection::Features::AllWordlistsImpact.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::ImpactBase }

  describe "#calculate" do

    it "returns the impact of all wordlists words of the edit's new revision text" do
      # 1 vulgarism, 2 pronouns, 0 biased = 3 bad
      old_text = Wikipedia::VandalismDetection::Text.new "Fuck you, you and all the others"
      # 3 vulgarism, 3 pronouns, 1 biased = 7 bad
      new_text = Wikipedia::VandalismDetection::Text.new "Fuck you great, fuck you, you and all the others sluts"

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 3.0 / (3.0 + 7.0)
    end

    it "returns 0.5 on both no terms in text revisions" do
      text = Wikipedia::VandalismDetection::Text.new "{{speedy deletion}}"

      old_revision = build(:old_revision, text: text)
      new_revision = build(:new_revision, text: text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      expect(@feature.calculate(edit)).to eq 0.5
    end

    it "returns 0.0 on emtpy clean text of old revision" do
      old_text = Wikipedia::VandalismDetection::Text.new "{{speedy deletion}}"
      new_text = Wikipedia::VandalismDetection::Text.new "fuck"

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      expect(@feature.calculate(edit)).to eq 0.0
    end

    it "returns 1.0 on emtpy clean text of new revision" do
      old_text = Wikipedia::VandalismDetection::Text.new "fuck"
      new_text = Wikipedia::VandalismDetection::Text.new "{{speedy deletion}}"

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      expect(@feature.calculate(edit)).to eq 1.0
    end
  end
end
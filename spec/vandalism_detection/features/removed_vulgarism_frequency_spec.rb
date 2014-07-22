require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RemovedVulgarismFrequency do

  before do
    @feature = Wikipedia::VandalismDetection::Features::RemovedVulgarismFrequency.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::FrequencyBase }

  describe "#calculate" do

    it "returns the number of removed vulgarism words relative to all removed words count" do
      # total 10 words, 3 vulgarism
      old_text = Wikipedia::VandalismDetection::Text.new "Old shit. Fuck you, fu*ck you $lut, you and all the others."
      new_text = Wikipedia::VandalismDetection::Text.new 'Old shit. New shit.'

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 3.0 / 10.0
    end

    it "returns 0.0 on emtpy removed clean text revisions" do
      old_text = Wikipedia::VandalismDetection::Text.new "Old shit. {{speedy deletion}}"
      new_text = Wikipedia::VandalismDetection::Text.new 'Old shit. New shit.'

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 0.0
    end
  end
end
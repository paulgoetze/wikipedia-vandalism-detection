require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RemovedAllWordlistsFrequency do

  before do
    @feature = Wikipedia::VandalismDetection::Features::RemovedAllWordlistsFrequency.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::FrequencyBase }

  describe "#calculate" do

    it "returns the removed number of all wordlists words relative to all removed words count" do
      # inserted: total 8 words, 1 vulgarism, 1 biased, 2 pronouns = 4 bad
      old_text = Wikipedia::VandalismDetection::Text.new 'Your old shit. Fuck you great, you and all the others.'
      new_text = Wikipedia::VandalismDetection::Text.new 'Your old shit.'

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 4.0 / 8.0
    end

    it "returns 0.0 on empty removed clean text" do
      old_text = Wikipedia::VandalismDetection::Text.new 'Your old shit. {{speedy deletion}}'
      new_text = Wikipedia::VandalismDetection::Text.new 'Your old shit.'

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 0.0
    end
  end
end
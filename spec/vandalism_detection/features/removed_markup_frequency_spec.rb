require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RemovedMarkupFrequency do

  before do
    @feature = Wikipedia::VandalismDetection::Features::RemovedMarkupFrequency.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the number of removed markup words relative to all removed words count" do
      # inserted: total 6 words, 2 markup
      old_text = Wikipedia::VandalismDetection::Text.new "[[Great]] old. It's [[Great]] man, this is [[amazing]]."
      new_text = Wikipedia::VandalismDetection::Text.new '[[Great]] old.'

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 2.0 / 6.0
    end

    it "returns 0.0 on emtpy removed text" do
      old_text = Wikipedia::VandalismDetection::Text.new "Great old. {{speedy deletion}}"
      new_text = Wikipedia::VandalismDetection::Text.new 'Great old. {{speedy deletion}} [[heading]]'

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 0.0
    end
  end
end
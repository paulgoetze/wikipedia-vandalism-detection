require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::NonAlphanumericRatio do

  before do
    @feature = Wikipedia::VandalismDetection::Features::NonAlphanumericRatio.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the non-alphanumeric to all letters ratio of the edit's new revision uncleaned inserted text" do
      old_text = Wikipedia::VandalismDetection::Text.new('t$xt')
      new_text = Wikipedia::VandalismDetection::Text.new 't$xt [[1A$% 4B6]] 8Cd?' # 7 non-alphanumeric letters of total 15 letters

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq (1.0 + 7) / (1.0 + 15)
    end

    it "returns 0.0 if no text inserted" do
      old_text = Wikipedia::VandalismDetection::Text.new("deletion text")
      new_text = Wikipedia::VandalismDetection::Text.new("text")

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      expect(@feature.calculate(edit)).to eq 0.0
    end
  end
end
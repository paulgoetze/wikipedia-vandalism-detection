require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::UpperCaseRatio do

  before do
    @feature = Wikipedia::VandalismDetection::Features::UpperCaseRatio.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the uppercase to all letters ratio of the edit's new revision cleaned inserted text" do
      old_text = Wikipedia::VandalismDetection::Text.new('text')
      new_text = Wikipedia::VandalismDetection::Text.new 'text [[1A 4B6 8Cd]]' # 3 uppercase letters of total 4 inserted letters

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq (1.0 + 3) / (1.0 + 4)
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
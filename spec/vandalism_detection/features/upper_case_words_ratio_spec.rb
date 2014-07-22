# encoding: UTF-8
require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::UpperCaseWordsRatio do

  before do
    @feature = Wikipedia::VandalismDetection::Features::UpperCaseWordsRatio.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the uppercase to all words ratio of the edit's new revision cleaned inserted text" do
      old_text = Wikipedia::VandalismDetection::Text.new('text')
      # 2 two capital (not numbers!) words of total 4 inserted, template {{23A}} is removed while cleaning!
      new_text = Wikipedia::VandalismDetection::Text.new "text [[HELLO you]] NICE boyß3 1990 {{23A}}"

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq (1.0 + 2) / (1.0 + 4)
    end

    it "returns 0.0 if no text inserted" do
      old_text = Wikipedia::VandalismDetection::Text.new("DELECTION text")
      new_text = Wikipedia::VandalismDetection::Text.new("text")

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      expect(@feature.calculate(edit)).to eq 0.0
    end
  end
end
require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::LongestWord do

  before do
    @feature = Wikipedia::VandalismDetection::Features::LongestWord.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the length of the edit's new revisions text's longest word" do
      old_text = Wikipedia::VandalismDetection::Text.new "1 7777777"
      new_text = Wikipedia::VandalismDetection::Text.new "1 7777777 22 a2c4e 4444 55555\n\n======head======\nfffff"

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 5
    end

    it "returns 0 on non inserted clean text" do
      old_text = Wikipedia::VandalismDetection::Text.new "1 22"
      new_text = Wikipedia::VandalismDetection::Text.new "1 22 {{speedy deletion}}"

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 0
    end
  end
end
require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::CharacterDiversity do

  before do
    @feature = Wikipedia::VandalismDetection::Features::CharacterDiversity.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the character diversity of the edit's new revision inserted text" do
      old_text = Wikipedia::VandalismDetection::Text.new('text')
      new_text = Wikipedia::VandalismDetection::Text.new 'text [[aa ab cdeefg]]' # 9 unique characters of total 14

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 14 ** (1.0 / 9)
    end

    it "returns 1.0 if no text inserted" do
      old_text = Wikipedia::VandalismDetection::Text.new("deletion text")
      new_text = Wikipedia::VandalismDetection::Text.new("text")

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 0.0
    end
  end
end
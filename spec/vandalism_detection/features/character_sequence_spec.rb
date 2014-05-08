require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::CharacterSequence do

  before do
    @feature = Wikipedia::VandalismDetection::Features::CharacterSequence.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base}

  describe "#calculate" do

    it "returns the number of the new revision's longest sequence of the same character" do
      old_text = Wikipedia::VandalismDetection::Text.new "a 666666"
      new_text = Wikipedia::VandalismDetection::Text.new "a 666666 4444ccc eeeefffff gggg g \n===hhhh===\n''fffaffff''"

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)

      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 5
    end

    it "returns 0 on non inserted text" do
      old_text = Wikipedia::VandalismDetection::Text.new "a 666666 4444ccc eeeefffff gggg g"
      new_text = Wikipedia::VandalismDetection::Text.new "a 666666 "

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)

      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 0
    end
  end
end
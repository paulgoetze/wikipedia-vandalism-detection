require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::CharacterSequence do

  before do
    @feature = Wikipedia::VandalismDetection::Features::CharacterSequence.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base}

  describe "#calculate" do

    it "returns the number of the new revision's longest sequence of the same character" do
      text = Wikipedia::VandalismDetection::Text.new "a 22 4444ccc eeeefffff gggg g \n===hhhh===\n''fffaffff''"
      edit = build :edit, new_revision: build(:new_revision, text: text)

      @feature.calculate(edit).should == 5
    end

    it "returns 0 on emtpy clean text" do
      text = Wikipedia::VandalismDetection::Text.new "{{speedy deletion}}"
      edit = build :edit, new_revision: build(:new_revision, text: text)

      @feature.calculate(edit).should == 0
    end
  end
end
require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::PersonalLife do

  before do
    @feature = Wikipedia::VandalismDetection::Features::PersonalLife.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::ContainsBase }

  describe "#calculate" do

    it "returns 1 if the edit comment includes 'personal life'" do
      comment = Wikipedia::VandalismDetection::Text.new "/* Personal life */ edited"
      edit = build :edit, new_revision: build(:new_revision, comment: comment)

      @feature.calculate(edit).should == 1
    end

    it "returns 0 on emtpy comment" do
      edit = build :edit, new_revision: build(:new_revision, comment: "")

      @feature.calculate(edit).should == 0
    end
  end
end
require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::Reverted do

  before do
    @feature = Wikipedia::VandalismDetection::Features::Reverted.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::ContainsBase }

  describe "#calculate" do

    ['rvt', 'rvv', 'revert'].each do |term|
      it "returns 1 if the edit comment includes '#{term}'" do
        comment = Wikipedia::VandalismDetection::Text.new "#{term} edited"
        edit = build :edit, new_revision: build(:new_revision, comment: comment)

        @feature.calculate(edit).should == 1
      end
    end

    it "returns 0 on emtpy comment" do
      edit = build :edit, new_revision: build(:new_revision, comment: "")

      @feature.calculate(edit).should == 0
    end
  end
end
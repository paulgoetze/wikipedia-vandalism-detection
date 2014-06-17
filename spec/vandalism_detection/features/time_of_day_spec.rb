require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::TimeOfDay do

  before do
    @feature = Wikipedia::VandalismDetection::Features::TimeOfDay.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the time of day as decimal value (hours)" do
      old_revision = build(:old_revision)
      new_revision = build(:new_revision, timestamp: '2012-12-09T05:30:36Z' )

      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 5.6
    end
  end
end
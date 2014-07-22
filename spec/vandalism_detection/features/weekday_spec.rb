require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::Weekday do

  before do
    @feature = Wikipedia::VandalismDetection::Features::Weekday.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the weekday as decimal value" do
      old_revision = build(:old_revision)
      new_revision = build(:new_revision, timestamp: '2012-12-11T05:30:36Z' )

      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 2 # Thuesday
    end
  end
end
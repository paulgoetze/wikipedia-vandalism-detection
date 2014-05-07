require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::TimeInterval do

  before do
    @feature = Wikipedia::VandalismDetection::Features::TimeInterval.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns time interval in days from old to new revision" do
      old_revision_time = '2014-11-27T18:00:00Z'
      new_revision_time = '2014-11-29T06:00:00Z'

      old_revision = build(:old_revision, timestamp: old_revision_time)
      new_revision = build(:new_revision, timestamp: new_revision_time)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 1.5
    end

    it "requests the time from Wikipedia API if old revisions timestamp is not given" do
      # to get api call, see:
      # https://en.wikipedia.org/w/api.php?action=query&prop=revisions&rvprop=timestamp&revids=327585467
      # => 2009-11-24T01:57:35Z
      new_revision_time = '2009-11-24T13:57:35Z'

      old_revision = build(:old_revision, id: '327585467', timestamp: nil)
      new_revision = build(:new_revision, id: '327607921', parent_id: '327585467', timestamp: new_revision_time)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 0.5
    end
  end
end
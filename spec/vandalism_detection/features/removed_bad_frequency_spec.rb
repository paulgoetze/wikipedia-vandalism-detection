require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RemovedBadFrequency do

  before do
    @feature = Wikipedia::VandalismDetection::Features::RemovedBadFrequency.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::FrequencyBase }

  describe "#calculate" do

    it "returns the number of removed bad words relative to all removed words count" do
      # inserted: total 10 words, 4 biased
      old_text = Wikipedia::VandalismDetection::Text.new "666 old. It's 666 man, this is 666, 666 a whatever."
      new_text = Wikipedia::VandalismDetection::Text.new '666 old.'

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 4.0 / 9.0
    end

    it "returns 0.0 on emtpy removed clean text" do
      old_text = Wikipedia::VandalismDetection::Text.new "whatever old. {{speedy deletion}}"
      new_text = Wikipedia::VandalismDetection::Text.new 'whatever old. whatever new.'

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 0.0
    end
  end
end
require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::BiasedFrequency do

  before do
    @feature = Wikipedia::VandalismDetection::Features::BiasedFrequency.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::FrequencyBase }

  describe "#calculate" do

    it "returns the inserted number of biased words relative to all inserted words count" do
      # inserted: total 10 words, 4 biased
      old_text = Wikipedia::VandalismDetection::Text.new 'Great old.'
      new_text = Wikipedia::VandalismDetection::Text.new "Great old. It's Great man, this is amazing, really a classic."

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 4.0 / 9.0
    end

    it "returns 0.0 on emtpy clean inserted text" do
      old_text = Wikipedia::VandalismDetection::Text.new 'Great old.'
      new_text = Wikipedia::VandalismDetection::Text.new "Great old. {{speedy deletion}}"

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 0.0
    end
  end
end
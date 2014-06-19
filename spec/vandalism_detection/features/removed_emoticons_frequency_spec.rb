require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RemovedEmoticonsFrequency do

  before do
    @feature = Wikipedia::VandalismDetection::Features::RemovedEmoticonsFrequency.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the number of removed emoticon words relative to all removed words count" do
      # inserted: total 6 words, 2 emoticons
      old_text = Wikipedia::VandalismDetection::Text.new ":) old. It's :P man:Pio, this is X-D."
      new_text = Wikipedia::VandalismDetection::Text.new ':) old.'

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 2.0 / 6.0
    end

    it "returns 0.0 on emtpy removed text" do
      old_text = Wikipedia::VandalismDetection::Text.new "Great old. {{speedy deletion}}"
      new_text = Wikipedia::VandalismDetection::Text.new 'Great old. {{speedy deletion}} :)'

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 0.0
    end
  end
end
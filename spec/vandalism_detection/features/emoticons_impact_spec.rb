require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::EmoticonsImpact do

  before do
    @feature = Wikipedia::VandalismDetection::Features::EmoticonsImpact.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the impact of emoticon words of the edit's new revision text" do
      # 3 emoticons
      old_text = ":) Hi you I got some :-X, you know ;)"

      # 4 emoticons
      new_text = ":) Hi (=you) I added another :-X you know ;)? (="

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 3.0 / (3.0 + 4.0)
    end

    it "returns 0.5 on both no terms in text revisions" do
      old_revision = build(:old_revision, text: "")
      new_revision = build(:new_revision, text: "")
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 0.5
    end

    it "returns 0.0 on emtpy text of old revision" do
      old_revision = build(:old_revision, text: "")
      new_revision = build(:new_revision, text: ":)")
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 0.0
    end

    it "returns 1.0 on emtpy text of new revision" do
      old_revision = build(:old_revision, text: ":)")
      new_revision = build(:new_revision, text: "")
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 1.0
    end
  end
end
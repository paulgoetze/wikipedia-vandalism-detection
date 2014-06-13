require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::MarkupImpact do

  before do
    @feature = Wikipedia::VandalismDetection::Features::MarkupImpact.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the impact of markup words of the edit's new revision text" do
      # 3 markup words
      old_text = "{{template}} <ref>reference</ref> [[hello]] hello"

      # 4 markup words
      new_text = "{{template}} <ref>reference</ref> [[hello]] cite dude"

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 3.0 / (3.0 + 4.0)
    end

    it "returns 0.5 on both no terms in text revisions" do
      text = ""

      old_revision = build(:old_revision, text: text)
      new_revision = build(:new_revision, text: text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 0.5
    end

    it "returns 0.0 on emtpy text of old revision" do
      old_text = ""
      new_text = "{{template}}"

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 0.0
    end

    it "returns 1.0 on emtpy text of new revision" do
      old_text = "{{template}}"
      new_text = ""

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 1.0
    end
  end
end
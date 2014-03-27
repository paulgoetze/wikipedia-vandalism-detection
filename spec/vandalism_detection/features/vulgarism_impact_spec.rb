require 'spec_helper'

describe  Wikipedia::VandalismDetection::Features::VulgarismImpact do

  before do
    @feature = Wikipedia::VandalismDetection::Features::VulgarismImpact.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::ImpactBase }

  describe "#calculate" do

    it "returns the impact of vulgarism words of the edit's new revision text" do
      # 1 vulgarism
      old_text = Wikipedia::VandalismDetection::Text.new "Fuck you, you and all the others"
      # 3 vulgarism
      new_text = Wikipedia::VandalismDetection::Text.new "Fuck you, fuck you, you and all the others sluts"

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 1.0 / (1.0 + 3.0)
    end

    it "returns 0.5 on both no terms in text revisions" do
      text = Wikipedia::VandalismDetection::Text.new "{{speedy deletion}}"

      old_revision = build(:old_revision, text: text)
      new_revision = build(:new_revision, text: text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 0.5
    end

    it "returns 0.0 on emtpy clean text of old revision" do
      old_text = Wikipedia::VandalismDetection::Text.new "{{speedy deletion}}"
      new_text = Wikipedia::VandalismDetection::Text.new "fuck"

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 0.0
    end

    it "returns 1.0 on emtpy clean text of new revision" do
      old_text = Wikipedia::VandalismDetection::Text.new "fuck"
      new_text = Wikipedia::VandalismDetection::Text.new "{{speedy deletion}}"

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_revision, old_revision: old_revision)

      @feature.calculate(edit).should == 1.0
    end
  end
end
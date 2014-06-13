require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::MarkupFrequency do

  before do
    @feature = Wikipedia::VandalismDetection::Features::MarkupFrequency.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the number of markup related words relative to all inserted words count" do
      # total 4 words, 3 markup
      old_text = Wikipedia::VandalismDetection::Text.new 'Old whatever.'
      new_text = Wikipedia::VandalismDetection::Text.new "Old whatever. {{template}} <ref>list</ref> [[heading]] boy."

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 3.0 / 4.0
    end

    it "returns 0.0 on no inserted text" do
      old_text = Wikipedia::VandalismDetection::Text.new 'Old guy.'
      new_text = Wikipedia::VandalismDetection::Text.new "Old guy."

      old_revision = build(:old_revision, text: old_text)
      new_revision = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 0.0
    end
  end
end
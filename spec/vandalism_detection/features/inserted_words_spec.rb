require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::InsertedWords do

  before do
    @feature = Wikipedia::VandalismDetection::Features::InsertedWords.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the number of the inserted words" do
      old_revision_text = Wikipedia::VandalismDetection::Text.new 'zero'
      new_revision_text = Wikipedia::VandalismDetection::Text.new 'zero one two three four five six' # 6 inserted

      old_revision = build(:old_revision, text: old_revision_text)
      new_revision = build(:new_revision, text: new_revision_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 6
    end

    it "returns 0 if no inserted text" do
      old_revision_text = Wikipedia::VandalismDetection::Text.new 'zero one'
      new_revision_text = Wikipedia::VandalismDetection::Text.new 'zero' # 0 inserted

      old_revision = build(:old_revision, text: old_revision_text)
      new_revision = build(:new_revision, text: new_revision_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 0
    end
  end
end
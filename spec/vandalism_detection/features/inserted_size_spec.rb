require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::InsertedSize do

  before do
    @feature = Wikipedia::VandalismDetection::Features::InsertedSize.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the size of the edit's new revisions inserted text sizes" do
      old_revision_text = Wikipedia::VandalismDetection::Text.new '123'
      new_revision_text = Wikipedia::VandalismDetection::Text.new '123 456789' # 6 inserted

      old_revision = build(:old_revision, text: old_revision_text)
      new_revision = build(:new_revision, text: new_revision_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 6
    end

    it "returns 0 if no inserted text " do
      old_revision_text = Wikipedia::VandalismDetection::Text.new '123 456789'
      new_revision_text = Wikipedia::VandalismDetection::Text.new '123' # 0 inserted

      old_revision = build(:old_revision, text: old_revision_text)
      new_revision = build(:new_revision, text: new_revision_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 0
    end
  end
end
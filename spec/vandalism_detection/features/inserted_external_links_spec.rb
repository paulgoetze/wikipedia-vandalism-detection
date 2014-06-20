require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::InsertedExternalLinks do

  before do
    @feature = Wikipedia::VandalismDetection::Features::InsertedExternalLinks.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the number of inserted external links" do
      old_revision_text = Wikipedia::VandalismDetection::Text.new '123'
      new_revision_text = Wikipedia::VandalismDetection::Text.new '123 [http://google.com Google] https://example.com'

      old_revision = build(:old_revision, text: old_revision_text)
      new_revision = build(:new_revision, text: new_revision_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 2
    end

    it "returns 0 if no inserted text" do
      old_revision_text = Wikipedia::VandalismDetection::Text.new '123 456789'
      new_revision_text = Wikipedia::VandalismDetection::Text.new '123' # 0 inserted

      old_revision = build(:old_revision, text: old_revision_text)
      new_revision = build(:new_revision, text: new_revision_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 0
    end
  end
end
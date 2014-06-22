require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RemovedWords do

  before do
    @feature = Wikipedia::VandalismDetection::Features::RemovedWords.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the number of the edit's removed words" do
      old_revision_text = Wikipedia::VandalismDetection::Text.new 'zero one two three four five six' # 6 removed
      new_revision_text = Wikipedia::VandalismDetection::Text.new 'zero'

      old_revision = build(:old_revision, text: old_revision_text)
      new_revision = build(:new_revision, text: new_revision_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 6
    end

    it "returns 0 if no removed text" do
      old_revision_text = Wikipedia::VandalismDetection::Text.new 'zero' # 0 removed
      new_revision_text = Wikipedia::VandalismDetection::Text.new 'zero one'

      old_revision = build(:old_revision, text: old_revision_text)
      new_revision = build(:new_revision, text: new_revision_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 0
    end
  end
end
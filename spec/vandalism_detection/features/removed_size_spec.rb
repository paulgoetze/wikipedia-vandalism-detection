require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RemovedSize do

  before do
    @feature = Wikipedia::VandalismDetection::Features::RemovedSize.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the size of the edit's new removed inserted text sizes" do
      old_revision_text = Wikipedia::VandalismDetection::Text.new '123 456789'
      new_revision_text = Wikipedia::VandalismDetection::Text.new '123' # 6 removed

      old_revision = build(:old_revision, text: old_revision_text)
      new_revision = build(:new_revision, text: new_revision_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 6
    end

    it "returns 0 if no removed text " do
      old_revision_text = Wikipedia::VandalismDetection::Text.new '123'
      new_revision_text = Wikipedia::VandalismDetection::Text.new '123 456789' # 0 removed

      old_revision = build(:old_revision, text: old_revision_text)
      new_revision = build(:new_revision, text: new_revision_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      expect(@feature.calculate(edit)).to eq 0
    end
  end
end
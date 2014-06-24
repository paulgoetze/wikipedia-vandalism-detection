require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::SizeIncrement do

  before do
    @feature = Wikipedia::VandalismDetection::Features::SizeIncrement.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns a negative increment on more removed texts" do
      old_revision_text = Wikipedia::VandalismDetection::Text.new '123456789' # length 9
      new_revision_text = Wikipedia::VandalismDetection::Text.new '123' # length 3

      old_revision = build(:old_revision, text: old_revision_text)
      new_revision = build(:new_revision, text: new_revision_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 3.0 - 9.0
    end

    it "returns a positive increment on more removed texts" do
      old_revision_text = Wikipedia::VandalismDetection::Text.new '123' # length 3
      new_revision_text = Wikipedia::VandalismDetection::Text.new '123456789' # length 9

      old_revision = build(:old_revision, text: old_revision_text)
      new_revision = build(:new_revision, text: new_revision_text)
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 9.0 - 3.0
    end
  end
end
require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::SameEditor do

  before do
    @feature = Wikipedia::VandalismDetection::Features::SameEditor.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "return 1.0 the previous editor is the same as the current" do
      old_revision = build(:old_revision, contributor: 'user name')
      new_revision = build(:new_revision, contributor: 'user name')

      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)
      @feature.calculate(edit).should == 1
    end

    it "returns 0.0 the previous editor is not the same as the current" do
      old_revision = build(:old_revision, contributor: 'user name')
      new_revision = build(:new_revision, contributor: 'other user name')

      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)
      @feature.calculate(edit).should == 0
    end
  end
end
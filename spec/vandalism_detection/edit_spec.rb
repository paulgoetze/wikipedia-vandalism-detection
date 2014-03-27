require 'spec_helper'

describe Wikipedia::VandalismDetection::Edit do

  before do
    @old_revision = build :old_revision
    @new_revision = build :new_revision

    @edit = Wikipedia::VandalismDetection::Edit.new(@old_revision, @new_revision)
  end

  it "has an old revision" do
    @edit.old_revision.should == @old_revision
  end

  it "has a new revision" do
    @edit.new_revision.should == @new_revision
  end

  it "raises an error if revisions are not sequent" do
    expect { Wikipedia::VandalismDetection::Edit.new(@new_revision, @old_revision) }.to raise_exception ArgumentError
  end

  describe "#serialize" do
    it "serializes the given parameters into a string" do
      @edit.serialize(:id, :text).should == "1:text 1\t2:text 2"
    end
  end
end
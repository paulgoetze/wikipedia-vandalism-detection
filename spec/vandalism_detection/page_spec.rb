require 'spec_helper'

describe Wikipedia::VandalismDetection::Page do

  describe "constants" do
    it "has a START_TAG constant" do
      Wikipedia::VandalismDetection::Page::START_TAG.should == '<page>'
    end

    it "has an END_Tag constant" do
      Wikipedia::VandalismDetection::Page::END_TAG.should == '</page>'
    end
  end

  before do
    @page = Wikipedia::VandalismDetection::Page.new
  end

  it "has a title" do
    @page.should respond_to :title
  end

  it "has an id" do
    @page.should respond_to :id
  end

  it "has revisions" do
    @page.revisions.should be_a Hash
  end

  it "has revisions with default {}" do
    @page.revisions.should be_empty
  end

  describe "#edits" do

    it {should respond_to :edits }

    it "returns an empty array if no revision is available" do
      @page.revisions.should be_empty
      @page.edits.should be_an(Array)
      @page.edits.should be_empty
    end

    it "resets the @revision_added flag to false" do
      @page.add_revision build(:empty_revision, id: '1')
      @page.edits
      @page.instance_variable_get(:@revision_added).should be_false
    end

    it "computes edits from the page's revisions" do
      @page.add_revision build(:empty_revision, id: '1')
      @page.add_revision build(:empty_revision, id: '3', parent_id: "2")
      @page.add_revision build(:empty_revision, id: '2', parent_id: "1")

      @page.edits.count.should == 2
    end

    it "computes edits of which each holds the parent page as reference" do
      @page.id = '1234'
      @page.title = 'Article'

      @page.add_revision build(:empty_revision, id: '1')
      @page.add_revision build(:empty_revision, id: '3', parent_id: "2")
      @page.add_revision build(:empty_revision, id: '2', parent_id: "1")

      @page.edits.each do |edit|
        edit.page.should == @page
      end
    end
  end

  describe "#add_revision" do

    it { should respond_to :add_revision }

    it "takes a revision and adds it to revisions" do
      revision = build :empty_revision
      expect { @page.add_revision(revision) }.to change(@page.revisions, :count).by(1)
    end

    it "sets the @revision_added flag to true after adding a revision" do
      revision = build :empty_revision
      @page.add_revision(revision)
      @page.instance_variable_get(:@revision_added).should be_true
    end

    it "only adds revisions which are no redirects" do
      revision = build :empty_revision, text: "#REDIRECT [[Redirect page name]]"
      expect { @page.add_revision(revision) }.not_to change(@page.revisions, :count)
      @page.instance_variable_get(:@revision_added).should be_false
    end
  end
end
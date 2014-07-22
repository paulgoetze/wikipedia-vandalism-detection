require 'spec_helper'

describe Wikipedia::VandalismDetection::Page do

  describe "constants" do
    it "has a START_TAG constant" do
      expect(Wikipedia::VandalismDetection::Page::START_TAG).to eq '<page>'
    end

    it "has an END_Tag constant" do
      expect(Wikipedia::VandalismDetection::Page::END_TAG).to eq '</page>'
    end
  end

  before do
    @page = Wikipedia::VandalismDetection::Page.new
  end

  it "has a title" do
    expect(@page).to respond_to :title
  end

  it "has an id" do
    expect(@page).to respond_to :id
  end

  it "has revisions" do
    expect(@page.revisions).to be_a Hash
  end

  it "has revisions with default {}" do
    expect(@page.revisions).to be_empty
  end

  describe "#edits" do

    it {should respond_to :edits }

    it "returns an empty array if no revision is available" do
      expect(@page.revisions).to be_empty
      expect(@page.edits).to be_an(Array)
      expect(@page.edits).to be_empty
    end

    it "resets the @revision_added flag to false" do
      @page.add_revision build(:empty_revision, id: '1')
      @page.edits
      expect(@page.instance_variable_get(:@revision_added)).to be false
    end

    it "computes edits from the page's revisions" do
      @page.add_revision build(:empty_revision, id: '1')
      @page.add_revision build(:empty_revision, id: '3', parent_id: "2")
      @page.add_revision build(:empty_revision, id: '2', parent_id: "1")

      expect(@page.edits.count).to eq 2
    end

    it "computes edits of which each holds the parent page as reference" do
      @page.id = '1234'
      @page.title = 'Article'

      @page.add_revision build(:empty_revision, id: '1')
      @page.add_revision build(:empty_revision, id: '3', parent_id: "2")
      @page.add_revision build(:empty_revision, id: '2', parent_id: "1")

      @page.edits.each do |edit|
        expect(edit.page).to eq @page
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
      expect(@page.instance_variable_get(:@revision_added)).to be true
    end

    it "only adds revisions which are no redirects" do
      revision = build :empty_revision, text: "#REDIRECT [[Redirect page name]]"
      expect { @page.add_revision(revision) }.not_to change(@page.revisions, :count)
      expect(@page.instance_variable_get(:@revision_added)).to be false
    end
  end
end
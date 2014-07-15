require 'spec_helper'

describe Wikipedia::VandalismDetection::Edit do

  before do
    @old_revision = build :old_revision
    @new_revision = build :new_revision
    @page_id = '1234'

    @edit = Wikipedia::VandalismDetection::Edit.new(@old_revision, @new_revision)
  end

  it "has an old revision" do
    @edit.old_revision.should == @old_revision
  end

  it "has a new revision" do
    @edit.new_revision.should == @new_revision
  end

  it "can be build with its parent page referenced" do
    page = build(:page, id: '1234', title: 'Page Title')
    edit = Wikipedia::VandalismDetection::Edit.new(@old_revision, @new_revision, page: page)
    edit.page.should == page
  end

  it "can be build with a page to get the id" do
    page_id = '1234'
    page = Wikipedia::VandalismDetection::Page.new
    page.id = page_id

    edit = Wikipedia::VandalismDetection::Edit.new(@old_revision, @new_revision, page: page)
    edit.page.id.should == page_id
  end

  it "can be build with a page to get the title" do
    page = Wikipedia::VandalismDetection::Page.new
    page_title = 'Article'
    page.title = page_title

    edit = Wikipedia::VandalismDetection::Edit.new(@old_revision, @new_revision, page: page)
    edit.page.title.should == page_title
  end

  describe "exception handling" do
    it "does not raise an error if page parameters are called" do
      edit = Wikipedia::VandalismDetection::Edit.new(@old_revision, @new_revision)
      expect { edit.page.id }.not_to raise_error
    end

    it "raises no error if revisions are not sequent" do
      expect { Wikipedia::VandalismDetection::Edit.new(@old_revision, @new_revision) }.not_to raise_error
    end

    it "raises an error if revisions are not sequent" do
      expect { Wikipedia::VandalismDetection::Edit.new(@new_revision, @old_revision) }.to raise_exception ArgumentError
    end
  end

  describe "#serialize" do
    it "serializes the given parameters into a string" do
      @edit.serialize(:id, :text).should == "1:text 1\t2:text 2"
    end
  end

  describe "#inserted_words" do
    it "returns the inserted words as array" do
      old_revision = build(:old_revision, text: "")
      new_revision = build(:new_revision, text: "inserted words")
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      edit.inserted_words.should == ['inserted', 'words']
    end

    it "returns the uncleaned text inserted words as array" do
      old_revision = build(:old_revision, text: "")
      new_revision = build(:new_revision, text: "[[inserted words]]")
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      edit.inserted_words.should == ['[[inserted', 'words]]']
    end
  end

  describe "#inserted_text" do
    it "returns the inserted text as Wikipedia::VandalismDetection::Text" do
      old_revision = build(:old_revision, text: "")
      new_revision = build(:new_revision, text: "inserted words")
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      edit.inserted_text.should == Wikipedia::VandalismDetection::Text.new('inserted words')
    end

    it "returns the uncleaned text inserted text as Wikipedia::VadalismDetection::Text" do
      old_revision = build(:old_revision, text: "")
      new_revision = build(:new_revision, text: "[[inserted words]]")
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      edit.inserted_text.should == Wikipedia::VandalismDetection::Text.new('[[inserted words]]')
    end
  end

  describe "#removed_words" do
    it "returns the removed words as array" do
      old_revision = build(:old_revision, text: "removed words")
      new_revision = build(:new_revision, text: "")
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      edit.removed_words.should == ['removed', 'words']
    end

    it "returns the uncleaned text rremoved words as array" do
      old_revision = build(:old_revision, text: "[[removed words]]")
      new_revision = build(:new_revision, text: "")
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      edit.removed_words.should == ['[[removed', 'words]]']
    end
  end

  describe "#removed_text" do
    it "returns the removed text as Wikipedia::VandalismDetection::Text" do
      old_revision = build(:old_revision, text: "removed words")
      new_revision = build(:new_revision, text: "")
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      edit.removed_text.should == Wikipedia::VandalismDetection::Text.new('removed words')
    end

    it "returns the uncleaned text removed text as Wikipedia::VadalismDetection::Text" do
      old_revision = build(:old_revision, text: "[[removed words]]")
      new_revision = build(:new_revision, text: "")
      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      edit.removed_text.should == Wikipedia::VandalismDetection::Text.new('[[removed words]]')
    end
  end
end

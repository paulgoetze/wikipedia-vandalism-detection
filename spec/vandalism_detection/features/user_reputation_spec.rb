require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::UserReputation do

  before do
    @feature = Wikipedia::VandalismDetection::Features::UserReputation.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the average number of contributor's reputation (WikiTrust) in the new revision" do
      #http://en.collaborativetrust.com/WikiTrust/RemoteAPI?method=wikimarkup&pageid=<page_id>&revid=<old_rev_id>
      # here: http://en.collaborativetrust.com/WikiTrust/RemoteAPI?method=wikimarkup&pageid=15580374&revid=604074768
      old_revision = build(:old_revision, id: '603070163')
      new_revision = build(:new_revision, id: '604074768', parent_id: '603070163', contributor: 'David Levy')
      page = Wikipedia::VandalismDetection::Page.new
      page.id = "15580374"

      edit = build(:edit, old_revision: old_revision, new_revision: new_revision, page: page)

      @feature.calculate(edit).should == 10.0
    end

    it "fetches the page id from the wikipedia API by page title if not available in edit" do
      #http://en.collaborativetrust.com/WikiTrust/RemoteAPI?method=wikimarkup&pageid=<page_id>&revid=<old_rev_id>
      # here: http://en.collaborativetrust.com/WikiTrust/RemoteAPI?method=wikimarkup&pageid=15580374&revid=604074768
      old_revision = build(:old_revision, id: '603070163')
      new_revision = build(:new_revision, id: '604074768', parent_id: '603070163', contributor: 'David Levy')
      page = Wikipedia::VandalismDetection::Page.new
      page.title = 'Main Page'

      edit = build(:edit, old_revision: old_revision, new_revision: new_revision, page: page)

      @feature.calculate(edit).should == 10.0
    end

    it "returns 0.0 WikiTrust if no contributions are available for given user" do
      #http://en.collaborativetrust.com/WikiTrust/RemoteAPI?method=wikimarkup&pageid=<page_id>&revid=<old_rev_id>
      # here: http://en.collaborativetrust.com/WikiTrust/RemoteAPI?method=wikimarkup&pageid=15580374&revid=604074768
      old_revision = build(:old_revision, id: '603070163')
      new_revision = build(:new_revision, id: '604074768', parent_id: '603070163', contributor: 'Artificial User')
      page = Wikipedia::VandalismDetection::Page.new
      page.id = "15580374"

      edit = build(:edit, old_revision: old_revision, new_revision: new_revision, page: page)

      @feature.calculate(edit).should == 0.0
    end
  end
end
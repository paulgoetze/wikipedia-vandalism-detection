require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::EditsPerUser do

  before do
    @feature = Wikipedia::VandalismDetection::Features::EditsPerUser.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    describe "online" do
      it "returns the number of previously submitted edit from the same IP or ID" do
        #http://en.wikipedia.org/w/api.php?action=query&format=json&list=usercontribs&ucuser=<name or ip>&ucprop=ids
        old_revision = build(:old_revision, id: '527136737')
        new_revision = build(:new_revision, id: '527137015', parent_id: '527136737',
                             contributor: '142.11.81.219', timestamp: '2012-12-09T05:30:07Z' )

        edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

        expect(@feature.calculate(edit)).to eq 1
      end
    end

    describe "offline" do
      before do
        page = build(:page)
        page.id = '1234'
        page.title = 'Page Title'

        # contributor: see factories/page.rb !
        old_revision = build(:new_revision, contributor: 'User')
        new_revision = build(:even_newer_revision, contributor: 'User')

        @edit = build(:edit, old_revision: old_revision, new_revision: new_revision, page: page)
      end

      it "does not use an API call if the edit has a page reference" do
        expect(Wikipedia).to_not receive :api_request
        @feature.calculate(@edit)
      end

      it "returns the number of previously submitted edit from the same IP or ID" do
        expect(@feature.calculate(@edit)).to eq 1
      end
    end
  end
end
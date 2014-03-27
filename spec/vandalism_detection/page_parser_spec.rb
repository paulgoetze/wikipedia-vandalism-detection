require 'spec_helper'

describe Wikipedia::VandalismDetection::PageParser do

  before do
    @parser =  Wikipedia::VandalismDetection::PageParser.new
  end

  describe "parser structure" do

    describe "#parse" do
      it "returns a Wikipedia::Page object" do
        xml = load_file('vandalism_on_wikipedia.xml')
        @page = @parser.parse xml
        @page.should be_a Wikipedia::VandalismDetection::Page
      end

      it "returns an empty Wikipedia::Page if the only revision is a redirect" do
        xml = load_file('redirect_page.xml')
        @page = @parser.parse xml
        @page.revisions.should be_empty
      end
    end
  end

  describe "a single page content parsing" do
    before do
      @xml = load_file('vandalism_on_wikipedia.xml')
      @page = @parser.parse @xml

      revision_1 = build :empty_revision, id: '398880281'
      revision_2 = build :empty_revision, id: '398880502', parent_id: '398880281'
      revision_3 = build :empty_revision, id: '398883278', parent_id: '398880502'
      revision_4 = build :empty_revision, id: '398883675', parent_id: '398883278'
      revision_5 = build :empty_revision, id: '398885233', parent_id: '398883675'

      @revisions = {revision_1.id => revision_1, revision_2.id => revision_2, revision_3.id => revision_3,
                    revision_4.id => revision_4, revision_5.id => revision_5}
    end

    it "can read a single page dump text input" do
      @page.should_not be_nil
    end

    it 'has a title' do
      @page.title.should == 'Vandalism on Wikipedia'
    end

    it 'has an id' do
      @page.id.should == '29753790'
    end


    describe "page's revisions" do
      it 'has the right number of revisions' do
        @page.revisions.count.should == 5
      end

      it "discards revisions with #REDIRECT content" do
        xml = load_file('page_with_redirects.xml')
        page = @parser.parse xml
        page.revisions.count.should == 2
      end

      it "has revisions each with the right id" do
        page_revisions = @page.revisions

        page_revisions.each do |key, value|
          value.id.should == @revisions[key].id
        end
      end

      it "has revisions each with the right parent_id" do
        page_revisions = @page.revisions

        page_revisions.each do |key, value|
          value.parent_id.should == @revisions[key].parent_id
        end
      end

      it "has revisions each with the right text" do
        xml = load_file('vandalism_on_wikipedia_simplified.xml')
        page = @parser.parse xml

        revision_1 = build :empty_revision, id: '1', text: "text\n\n\n        1\n\n      "
        revision_2 = build :empty_revision, id: '2', text: 'text 2'
        revision_3 = build :empty_revision, id: '3', text: 'text 3'
        revision_4 = build :empty_revision, id: '4', text: 'text 4'
        revision_5 = build :empty_revision, id: '5', text: 'text 5'

        revisions = {revision_1.id => revision_1, revision_2.id => revision_2, revision_3.id => revision_3,
                      revision_4.id => revision_4, revision_5.id => revision_5}

        page.revisions.each do |key, value|
          value.text.should == revisions[key].text
        end
      end

      it "has revisions each with the right comment" do
        xml = load_file('vandalism_on_wikipedia_simplified.xml')
        page = @parser.parse xml

        revision_1 = build :empty_revision, id: '1', comment: "comment\n\n        1\n\n      "
        revision_2 = build :empty_revision, id: '2', comment: 'comment 2'
        revision_3 = build :empty_revision, id: '3'
        revision_4 = build :empty_revision, id: '4'
        revision_5 = build :empty_revision, id: '5', comment: 'comment 3'

        revisions = {revision_1.id => revision_1, revision_2.id => revision_2, revision_3.id => revision_3,
                     revision_4.id => revision_4, revision_5.id => revision_5}

        page.revisions.each do |key, value|
          value.comment.should == revisions[key].comment
        end
      end

      describe "contributor properties" do
        before do
          xml = load_file('vandalism_on_wikipedia_simplified.xml')
          @page = @parser.parse xml

          revision_1 = build :empty_revision, id: '1', contributor: '1'
          revision_2 = build :empty_revision, id: '2', contributor: '10', contributor_username: 'user'
          revision_3 = build :empty_revision, id: '3', contributor: '11', contributor_username: 'user'
          revision_4 = build :empty_revision, id: '4', contributor: '12', contributor_username: 'user'
          revision_5 = build :empty_revision, id: '5', contributor: '2'

          @revisions = {revision_1.id => revision_1, revision_2.id => revision_2, revision_3.id => revision_3,
                       revision_4.id => revision_4, revision_5.id => revision_5}
        end

        it "has revisions each with the right contributor id" do
          @page.revisions.each do |key, value|
            value.contributor_id.should == @revisions[key].contributor_id
          end
        end

        it "has revisions each with the right contributor ip" do
          @page.revisions.each do |key, value|
            value.contributor_ip.should == @revisions[key].contributor_ip
          end
        end

        it "has revisions each with the right contributor username" do
          @page.revisions.each do |key, value|
            value.contributor_username.should == @revisions[key].contributor_username
          end
        end
      end

      it "has revisions each with the right timestamp" do
        xml = load_file('vandalism_on_wikipedia_simplified.xml')
        page = @parser.parse xml

        revision_1 = build :empty_revision, id: '1', timestamp: 'time 1'
        revision_2 = build :empty_revision, id: '2', timestamp: 'time 2'
        revision_3 = build :empty_revision, id: '3', timestamp: 'time 3'
        revision_4 = build :empty_revision, id: '4', timestamp: 'time 4'
        revision_5 = build :empty_revision, id: '5', timestamp: 'time 5'

        revisions = {revision_1.id => revision_1, revision_2.id => revision_2, revision_3.id => revision_3,
                     revision_4.id => revision_4, revision_5.id => revision_5}

        page.revisions.each do |key, value|
          value.timestamp.should == revisions[key].timestamp
        end
      end

    end
  end
end
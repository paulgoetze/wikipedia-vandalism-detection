require 'spec_helper'

describe Wikipedia::VandalismDetection::RevisionParser do

  before do
    @parser =  Wikipedia::VandalismDetection::RevisionParser.new
    @xml = load_file('revision_simplified.xml')

    @revision = @parser.parse @xml
    @expected_revision = build(:empty_revision,
                               id: 'id1',
                               parent_id: 'parentid1',
                               timestamp: 'time1',
                               contributor: 'ip1',
                               comment: 'comment 1',
                               text: "text 1",
                               sha1: 'hash1')
  end

  describe "#parse" do
    it "returns a Wikipedia::Revision object" do
      expect(@revision).to be_a Wikipedia::VandalismDetection::Revision
    end

    it "returns a revision with only the configured properties" do
      @revision = @parser.parse(@xml, only: [:id, :parent_id])

      [:id, :parent_id].each do |attr|
        expect(@revision.send(attr)).not_to be_nil
      end

      [:timestamp, :contributor, :sha1].each do |attr|
        expect(@revision.send(attr)).to be_nil
      end

      [:comment, :text].each do |attr|
        expect(@revision.send(attr)).to eq ""
      end
    end
  end

  describe "a single revison content parsing" do
    it "can read a single revsion dump text input" do
      expect(@revision).to_not be_nil
    end

    [:id, :timestamp, :contributor, :comment, :text, :sha1].each do |attr|
      it "has the expected #{attr}" do
        expect(@revision.send(attr)).to eq @expected_revision.send(attr)
      end
    end
  end
end
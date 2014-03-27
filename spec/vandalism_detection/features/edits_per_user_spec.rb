require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::EditsPerUser do

  before do
    @feature = Wikipedia::VandalismDetection::Features::EditsPerUser.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    it "returns the number of previously submitted edit from the same IP or ID" do
      #http://en.wikipedia.org/w/api.php?action=query&format=json&list=usercontribs&ucuser=<name or ip>&ucprop=ids
      old_revision = build(:old_revision, id: '527136737')
      new_revision = build(:new_revision, id: '527137015', parent_id: '527136737', contributor: '142.11.81.219')

      edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

      @feature.calculate(edit).should == 2
    end
  end
end
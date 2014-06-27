require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::AnonymityPrevious do

  before do
    @feature = Wikipedia::VandalismDetection::Features::AnonymityPrevious.new
  end

  it { should be_a Wikipedia::VandalismDetection::Features::Base }

  describe "#calculate" do

    context "both contributors are given" do
      it "return 1.0 in case of an registered previous editor" do
        old_revision = build(:old_revision, contributor: 'Peter')
        new_revision = build(:new_revision)
        edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

        @feature.calculate(edit).should == 1
      end

      it "returns 0.0 in case of an anonymous previous editor" do
        old_revision = build(:old_revision, contributor: '137.163.16.199')
        new_revision = build(:new_revision)
        edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

        @feature.calculate(edit).should == 0
      end
    end

    context "previous contributor not given" do
      it "requests the user from Wikipedia API and returns 1 in case of a registered previous editor" do
        old_revision = build(:old_revision, id: '324557983', contributor: nil)
        new_revision = build(:new_revision, id: '329962649', parent_id: '324557983', contributor: 'Tomaxer')

        edit = build(:edit, old_revision: old_revision, new_revision: new_revision)
        @feature.calculate(edit).should == 1
      end

      it "requests the user from Wikipedia API and returns 0 in case of an anonymous previous editor" do # also same editor!
        old_revision = build(:old_revision, id: '328774110', contributor: nil)
        new_revision = build(:new_revision, id: '328774035', parent_id: '328774110')

        edit = build(:edit, old_revision: old_revision, new_revision: new_revision)
        @feature.calculate(edit).should == 0
      end

      it "returns missing if old reivision is not available anymore" do
        # to get api call, see:
        # https://en.wikipedia.org/w/api.php?action=query&prop=revisions&rvprop=timestamp&revids=325218985
        # <rev revid="325218985"/>

        old_revision = build(:old_revision, id: '325218985', contributor: nil)
        new_revision = build(:new_revision, id: '326980599', parent_id: '325218985')
        edit = build(:edit, old_revision: old_revision, new_revision: new_revision)

        @feature.calculate(edit).should == Wikipedia::VandalismDetection::Features::MISSING_VALUE
      end
    end
  end
end
require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::EditsPerUser do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    describe 'online' do
      it 'returns the number of previous edits from same IP or ID' do
        # https://en.wikipedia.org/w/api.php?action=query&format=json&list=usercontribs&ucuser=<name or ip>&ucprop=ids
        old_rev = build(:old_revision, id: '527136737')
        new_rev = build(
          :new_revision,
          id: '527137015',
          parent_id: '527136737',
          contributor: '142.11.81.219',
          timestamp: '2012-12-09T05:30:07Z'
        )

        edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

        expect(subject.calculate(edit)).to eq 1
      end
    end

    describe 'offline' do
      before do
        page = build(:page, id: '1234', title: 'Page Title')

        # contributor: see factories/page.rb !
        old_rev = build(:new_revision, contributor: 'User')
        new_rev = build(:even_newer_revision, contributor: 'User')

        @edit = build(
          :edit,
          old_revision: old_rev,
          new_revision: new_rev,
          page: page
        )
      end

      it 'does not use an API call if the edit has a page reference' do
        expect(Wikipedia).to_not receive :api_request
        subject.calculate(@edit)
      end

      it 'returns the number of previous edits from the same IP or ID' do
        expect(subject.calculate(@edit)).to eq 1
      end
    end
  end
end

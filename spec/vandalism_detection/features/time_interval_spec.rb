require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::TimeInterval do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns time interval in days from the old to the new revision' do
      old_timestamp = '2014-11-27T18:00:00Z'
      new_timestamp = '2014-11-29T06:00:00Z'

      old_rev = build(:old_revision, timestamp: old_timestamp)
      new_rev = build(:new_revision, timestamp: new_timestamp)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 1.5
    end

    it 'requests the time from API if no old revisions timestamp is given' do
      # to get api call, see:
      # https://en.wikipedia.org/w/api.php?action=query&prop=revisions&rvprop=timestamp&revids=331655535
      # => 2001-11-29T03:27:34Z
      new_timestamp = '2001-11-06T13:16:13Z'

      old_rev = build(:old_revision, id: '331655534', timestamp: nil)
      new_rev = build(
        :new_revision,
        id: '331655535',
        parent_id: '331655534',
        timestamp: new_timestamp
      )

      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0.5
    end

    it 'returns missing if the old reivision is not available anymore' do
      # to get api call, see:
      # https://en.wikipedia.org/w/api.php?action=query&prop=revisions&rvprop=timestamp&revids=325218985
      # <rev revid="325218985"/>
      new_timestamp = '2011-11-11T01:00:00Z'

      old_rev = build(:old_revision, id: '325218985', timestamp: nil)
      new_rev = build(
        :new_revision,
        id: '326980599',
        parent_id: '325218985',
        timestamp: new_timestamp
      )

      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq Features::MISSING_VALUE
    end
  end
end

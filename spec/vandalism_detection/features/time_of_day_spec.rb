require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::TimeOfDay do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the time of day as decimal value (hours)' do
      old_rev = build(:old_revision)
      new_rev = build(:new_revision, timestamp: '2012-12-09T05:30:36Z')

      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 5.6
    end
  end
end

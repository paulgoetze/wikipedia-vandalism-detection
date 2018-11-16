require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::Weekday do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the weekday as decimal value' do
      old_rev = build(:old_revision)
      new_rev = build(:new_revision, timestamp: '2012-12-11T05:30:36Z')

      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 2 # Thuesday
    end
  end
end

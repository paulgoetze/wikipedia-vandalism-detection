require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RemovedBadFrequency do
  it { is_expected.to be_a Features::FrequencyBase }

  describe '#calculate' do
    it 'returns the number of removed bad words over all removed words' do
      # inserted: total 10 words, 4 biased
      old_text = Text.new('666 old. It’s 666 man, this is 666, 666 a whatever.')
      new_text = Text.new('666 old.')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 4.0 / 9.0
    end

    it 'returns 0.0 for an emtpy removed clean text' do
      old_text = Text.new('whatever old. {{speedy deletion}}')
      new_text = Text.new('whatever old. whatever new.')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

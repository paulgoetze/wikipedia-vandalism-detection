require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::SexFrequency do
  it { is_expected.to be_a Features::FrequencyBase }

  describe '#calculate' do
    it 'returns the number of vulgarism words over all words' do
      # total 6 words, 3 bad
      old_text = Text.new('Old whatever.')
      new_text = Text.new('Old whatever. New sex contents. Penis, dildos, boy.')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 3.0 / 6.0
    end

    it 'returns 0.0 for an emtpy clean text in the new revision' do
      old_text = Text.new('Old guy.')
      new_text = Text.new('Old guy. {{speedy deletion}}')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

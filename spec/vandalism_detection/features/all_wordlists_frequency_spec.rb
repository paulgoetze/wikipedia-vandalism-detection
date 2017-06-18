require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::AllWordlistsFrequency do
  it { is_expected.to be_a Features::FrequencyBase }

  describe '#calculate' do
    it 'returns the inserted number of all lists words over all inserted' do
      # inserted: total 7 words, 1 vulgarism, 1 biased, 1 pronouns = 3 bad
      old_text = Text.new('Your old shit. ')
      new_text = Text.new('Your old shit. Fuck you great, and all the others.')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 3.0 / 7.0
    end

    it 'returns 0.0 on empty clean inserted text' do
      old_text = Text.new('Your old shit. ')
      new_text = Text.new('Your old shit. {{speedy deletion}}')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

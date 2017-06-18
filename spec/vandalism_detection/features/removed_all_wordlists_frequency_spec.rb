require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RemovedAllWordlistsFrequency do
  it { is_expected.to be_a Features::FrequencyBase }

  describe '#calculate' do
    it 'returns the number of removed lists words over all removed words' do
      # inserted: total 7 words, 1 vulgarism, 1 biased, 2 pronouns = 4 bad
      old_text = Text.new('Your old shit. Fuck you great, you and the others.')
      new_text = Text.new('Your old shit.')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 4.0 / 7.0
    end

    it 'returns 0.0 for an empty removed clean text' do
      old_text = Text.new('Your old shit. {{speedy deletion}}')
      new_text = Text.new('Your old shit.')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

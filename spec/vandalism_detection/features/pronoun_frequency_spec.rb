require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::PronounFrequency do
  it { is_expected.to be_a Features::FrequencyBase }

  describe '#calculate' do
    it 'returns the number of pronouns relative to all words count' do
      # total 10 words, 6 pronouns
      old_text = Text.new('Your old.')
      new_text = Text.new('Your old. I was you if You was we are ourselves us.')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 6.0 / 10.0
    end

    it 'returns 0.0 for an emtpy clean text in the new revision' do
      old_text = Text.new('Your old.')
      new_text = Text.new('Your old. {{speedy deletion}}')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

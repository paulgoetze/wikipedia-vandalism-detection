require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RemovedPronounFrequency do
  it { is_expected.to be_a Features::FrequencyBase }

  describe '#calculate' do
    it 'returns the number of removed pronouns over all removed words' do
      # total 10 words, 6 pronouns
      old_text = Text.new('Your old. I was you if You was We are ourselves us.')
      new_text = Text.new('Your old.')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 6.0 / 10.0
    end

    it 'returns 0.0 for an emtpy removed clean text in the new revision' do
      old_text = Text.new('Your old. {{speedy deletion}}')
      new_text = Text.new('Your old. My inserted.')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

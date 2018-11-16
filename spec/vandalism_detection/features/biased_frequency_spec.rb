require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::BiasedFrequency do
  it { is_expected.to be_a Features::FrequencyBase }

  describe '#calculate' do
    it 'returns the inserted number of biased words over all inserted words' do
      # inserted: total 7 words, 3 biased
      old_text = Text.new('Great old.')
      new_text = Text.new('Great old. This is so great, really a classic.')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 3.0 / 7.0
    end

    it 'returns 0.0 on emtpy clean inserted text' do
      old_text = Text.new('Great old.')
      new_text = Text.new('Great old. {{speedy deletion}}')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

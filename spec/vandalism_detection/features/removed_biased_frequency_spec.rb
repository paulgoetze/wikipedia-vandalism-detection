require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RemovedBiasedFrequency do
  it { is_expected.to be_a Features::FrequencyBase }

  describe '#calculate' do
    it 'returns the number of removed biased words over removed words count' do
      # inserted: total 7 words, 3 biased (great, really, classic)
      old_text = Text.new('Great old. This is so great, really a classic.')
      new_text = Text.new('Great old.')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 3.0 / 7.0
    end

    it 'returns 0.0 on emtpy removed clean text' do
      old_text = Text.new('Great old. {{speedy deletion}}')
      new_text = Text.new('Great old. Great new.')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

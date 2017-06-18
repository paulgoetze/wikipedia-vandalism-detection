require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::TermFrequency do
  it { is_expected.to be_a Features::FrequencyBase }

  describe '#calculate' do
    it 'returns the average relative frequency of inserted words' do
      # removed [you, I], added [you, you, you, we]
      # for [you, we] compute frequency in old_text and average for all words
      # here: [you] is 6x in new text, [we] is 3x in new text of total 10 words
      # avg = (6/10 + 3/10)/2
      old_text = Text.new("we\nwe\nyou\nyou\nyou\nI\nyou\nI\n")
      new_text = Text.new("we\nwe\nyou\nyou\nI\nyou\n''(you''\nyou\nyou\n[[we]])\n")

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq(((6.0 / 10.0) + (3.0 / 10.0)) / 2.0)
    end

    it 'returns 0.0 on emtpy clean text revisions' do
      text = Text.new('{{speedy deletion}}')

      old_rev = build(:old_revision, text: text)
      new_rev = build(:new_revision, text: text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

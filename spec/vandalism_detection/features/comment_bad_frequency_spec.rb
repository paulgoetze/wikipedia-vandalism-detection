require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::CommentBadFrequency do
  it { is_expected.to be_a Features::FrequencyBase }

  describe '#calculate' do
    it 'returns the number of bad words in comment over all words' do
      # total 11 words, 7 bad words
      comment = Text.new('666 was 666 if 666 was 666 and guy are 666')

      old_rev = build(:old_revision)
      new_rev = build(:new_revision, comment: comment)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 6.0 / 11.0
    end

    it 'returns 0.0 on emtpy clean text comment' do
      comment = Text.new('{{speedy deletion}}')

      old_rev = build(:old_revision)
      new_rev = build(:new_revision, comment: comment)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

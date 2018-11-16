require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::CommentBiasedFrequency do
  it { is_expected.to be_a Features::FrequencyBase }

  describe '#calculate' do
    it 'returns the number of biased words in comment over all words' do
      # total 10 words, 3 biased
      comment = Text.new('It’s Great man, this is amazing, really a classic.')

      old_rev = build(:old_revision)
      new_rev = build(:new_revision, comment: comment)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 4.0 / 9.0
    end

    it 'returns 0.0 for an emtpy clean text comment in the new revision' do
      comment = Text.new('{{speedy deletion}}')

      old_rev = build(:old_revision)
      new_rev = build(:new_revision, comment: comment)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

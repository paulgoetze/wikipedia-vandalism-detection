require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::CommentPronounFrequency do
  it { is_expected.to be_a Features::FrequencyBase }

  describe '#calculate' do
    it 'returns the number of pronouns in comment over all words count' do
      # total 12 words, 7 pronouns
      comment = Text.new('I was you if You was Me and we are ourselves us')

      old_rev = build(:old_revision)
      new_rev = build(:new_revision, comment: comment)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 7.0 / 12.0
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

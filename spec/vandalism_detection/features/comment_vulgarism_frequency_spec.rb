require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::CommentVulgarismFrequency do
  it { is_expected.to be_a Features::FrequencyBase }

  describe '#calculate' do
    it 'returns the number of vulgarism words in comment over all words' do
      # total 7 words, 2 vulgarism
      comment = Text.new('Fuck you bitch. This is my change!')

      old_rev = build(:old_revision)
      new_rev = build(:new_revision, comment: comment)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 2.0 / 7.0
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

require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::CommentMarkupFrequency do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the number of markup words in comment over all words' do
      # total 7 words, 3 markup
      comment = Text.new('[[Content]] is not always {{simple}} to [[produce]]')

      old_rev = build(:old_revision)
      new_rev = build(:new_revision, comment: comment)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 3.0 / 7.0
    end

    it 'returns 0.0 on emtpy text comment' do
      comment = Text.new

      old_rev = build(:old_revision)
      new_rev = build(:new_revision, comment: comment)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

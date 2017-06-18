require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::EmoticonsFrequency do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the number of emoticons over all words' do
      # total 8 words, 3 emoticons
      old_text = Text.new('Old :-).')
      new_text = Text.new('Old :-). ;) love icons and emoticons? :D :P, yeah.')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 3.0 / 8.0
    end

    it 'returns 0.0 on emtpy clean text revisions' do
      old_text = Text.new('Old :-).')
      new_text = Text.new('Old :-). {{speedy deletion}}')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

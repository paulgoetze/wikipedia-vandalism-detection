require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::UpperToLowerCaseRatio do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the upper to lower letters ratio of the inserted text' do
      old_text = Text.new('text')
      # 3 uppercase letters, 4 lowercase letters
      new_text = Text.new('text [[1aA 4B6 8Cd ef]]')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq((1.0 + 3) / (1.0 + 4))
    end

    it 'returns 0.0 if no text inserted' do
      old_text = Text.new('deletion text')
      new_text = Text.new('text')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

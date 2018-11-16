require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::UpperCaseRatio do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the uppercase to all letters ratio of inserted clean text' do
      old_text = Text.new('text')
      # 3 uppercase letters of total 4 inserted letters
      new_text = Text.new('text [[1A 4B6 8Cd]]')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq((1.0 + 3) / (1.0 + 4))
    end

    it 'returns 0.0 if no text was inserted' do
      old_text = Text.new('deletion text')
      new_text = Text.new('text')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

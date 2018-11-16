require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::CharacterDiversity do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the character diversity of the new inserted text' do
      old_text = Text.new('text')
      # 9 unique characters of total 14
      new_text = Text.new('text [[aa ab cdeefg]]')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 14**(1.0 / 9)
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

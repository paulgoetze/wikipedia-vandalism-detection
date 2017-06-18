require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::CharacterSequence do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the number of the new revision’s longest character sequence' do
      old_text = Text.new('a 666666')
      new_text = Text.new("a 666666 4444ccc eefffff gggg g ''fffaffff''")

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)

      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 5
    end

    it 'returns 0 if no text was inserted' do
      old_text = Text.new('a 666666 4444ccc eeeefffff gggg g')
      new_text = Text.new('a 666666 ')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)

      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0
    end
  end
end

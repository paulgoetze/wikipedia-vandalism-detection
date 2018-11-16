require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RemovedMarkupFrequency do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the number of removed markup words over all removed words' do
      # inserted: total 5 removed words, 2 markup
      old_text = Text.new('[[Great]] old. It is [[Great]] man, [[amazing]].')
      new_text = Text.new('[[Great]] old.')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 2.0 / 5.0
    end

    it 'returns 0.0 on emtpy removed text' do
      old_text = Text.new('Great old. {{speedy deletion}}')
      new_text = Text.new('Great old. {{speedy deletion}} [[heading]]')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

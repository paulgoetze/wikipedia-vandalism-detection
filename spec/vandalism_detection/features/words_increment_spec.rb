require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::WordsIncrement do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns a negative increment for more removed texts' do
      old_text = Text.new('one two three four five six seven eight') # length 8
      new_text = Text.new('one two three') # length 3

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 3.0 - 8.0
    end

    it 'returns a positive increment on more removed texts' do
      old_text = Text.new('one two three') # length 3
      new_text = Text.new('one two three four five six seven eight') # length 8

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 8.0 - 3.0
    end
  end
end

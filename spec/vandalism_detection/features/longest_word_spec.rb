require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::LongestWord do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the length of the longest word in the new revision text' do
      old_text = Text.new('1 7777777')
      new_text = Text.new("1 7777777 22 a2c4e 333 55555\n======head======\nfff")

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 5
    end

    it 'returns 0 on non inserted clean text' do
      old_text = Text.new('1 22')
      new_text = Text.new('1 22 {{speedy deletion}}')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0
    end
  end
end

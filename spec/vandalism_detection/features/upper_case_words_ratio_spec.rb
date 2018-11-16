# encoding: UTF-8

require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::UpperCaseWordsRatio do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the uppercase/all words ratio of the inserted cleaned text' do
      old_text = Text.new('text')
      # 2 two capital (not numbers!) words of total 4 inserted.
      # The template {{23A}} is removed while cleaning.
      new_text = Text.new('text [[HELLO you]] NICE boyß3 1990 {{23A}}')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq((1.0 + 2) / (1.0 + 4))
    end

    it 'returns 0.0 if no text inserted' do
      old_text = Text.new('DELECTION text')
      new_text = Text.new('text')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RemovedEmoticonsFrequency do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the number of removed emoticon words over all removed words' do
      # inserted: total 6 words, 2 emoticons
      old_text = Text.new(':) old. It’s :P man:Pio, this is X-D.')
      new_text = Text.new(':) old.')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 2.0 / 6.0
    end

    it 'returns 0.0 on emtpy removed text' do
      old_text = Text.new('Great old. {{speedy deletion}}')
      new_text = Text.new('Great old. {{speedy deletion}} :)')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

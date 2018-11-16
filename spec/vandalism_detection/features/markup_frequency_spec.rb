require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::MarkupFrequency do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the number of markup related words over all inserted words' do
      # total 4 words, 3 markup
      old_text = Text.new('Old whatever.')
      new_text = Text.new('Old whatever. {{template}} <ref>list</ref> [[heading]] boy.')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 3.0 / 4.0
    end

    it 'returns 0.0 on no inserted text' do
      text = 'Old guy.'
      old_text = Text.new(text)
      new_text = Text.new(text)

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

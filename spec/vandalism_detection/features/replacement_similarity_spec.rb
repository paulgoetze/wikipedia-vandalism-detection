require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::ReplacementSimilarity do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the similarity of the deleted text to inserted in exchange' do
      old_text = Text.new('this is Mr. Dixon')
      new_text = Text.new('this is Mr. Dicksonx')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)

      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0.8133333333333332
    end

    it 'returns 0 if the old revision text is empty' do
      old_rev = build(:old_revision, text: '')
      new_rev = build(:new_revision, text: '{{speedy deletion}}')

      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0
    end

    it 'returns 0 if the new revision text is empty' do
      old_rev = build(:old_revision, text: '{{speedy deletion}}')
      new_rev = build(:new_revision, text: '')

      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0
    end
  end
end

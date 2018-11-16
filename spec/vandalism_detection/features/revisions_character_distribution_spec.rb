require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RevisionsCharacterDistribution do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the KL-Divergence of the inserted characters distribution' do
      old_text = Text.new('old text old text is standing here')
      new_text = Text.new('old text [[new inserted text]] given dero 9')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0.6312751553366259
    end

    it 'returns missing value if new revision text is empty' do
      old_text = Text.new('old text')
      new_text = Text.new

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq Features::MISSING_VALUE
    end

    it 'returns missing value if the old revision text is empty' do
      old_text = Text.new
      new_text = Text.new('new text')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq Features::MISSING_VALUE
    end
  end
end

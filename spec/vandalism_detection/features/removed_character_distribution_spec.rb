require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RemovedCharacterDistribution do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the KL-Divergence of the removed characters distribution' do
      old_text = Text.new('old text [[new inserted text]] given dero 9')
      new_text = Text.new('old text')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 1.6609633564650683
    end

    it 'returns a missing value if no alphanumeric characters were removed' do
      old_text = Text.new('old text !* [[?]]')
      new_text = Text.new('old text')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq Features::MISSING_VALUE
    end

    it 'returns a missing value if no text was inserted' do
      old_text = Text.new('text')
      new_text = Text.new('deletion text')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq Features::MISSING_VALUE
    end
  end
end

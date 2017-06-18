require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::SexImpact do
  it { is_expected.to be_a Features::ImpactBase }

  describe '#calculate' do
    it 'returns the impact of sex words of the new revision text' do
      # 3 sex words
      old_text = Text.new('Penis, old text dildo, breast it')

      # 4 sex words
      new_text = Text.new('Penis, old text dildo, breast anal it')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 3.0 / (3.0 + 4.0)
    end

    it 'returns 0.5 if both revision text have no terms' do
      text = Text.new('{{speedy deletion}}')

      old_rev = build(:old_revision, text: text)
      new_rev = build(:new_revision, text: text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.5
    end

    it 'returns 0.0 for an emtpy clean text in the old revision' do
      old_text = Text.new('{{speedy deletion}}')
      new_text = Text.new('anal')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end

    it 'returns 1.0 for an emtpy clean text in the new revision' do
      old_text = Text.new('anal')
      new_text = Text.new('{{speedy deletion}}')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 1.0
    end
  end
end

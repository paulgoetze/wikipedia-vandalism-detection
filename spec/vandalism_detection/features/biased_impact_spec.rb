require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::BiasedImpact do
  it { is_expected.to be_a Features::ImpactBase }

  describe '#calculate' do
    it 'returns the impact of biased words of the new revision text' do
      # 1 vulgarism
      old_text = Text.new('this is classic!')
      # 3 vulgarism
      new_text = Text.new('This is classic, legendary and amazing!')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 1.0 / (1.0 + 3.0)
    end

    it 'returns 0.5 on both no terms in text revisions' do
      text = Text.new('{{speedy deletion}}')

      old_rev = build(:old_revision, text: text)
      new_rev = build(:new_revision, text: text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.5
    end

    it 'returns 0.0 on emtpy clean text of old revision' do
      old_text = Text.new('{{speedy deletion}}')
      new_text = Text.new('great')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end

    it 'returns 1.0 on emtpy clean text of new revision' do
      old_text = Text.new('great')
      new_text = Text.new('{{speedy deletion}}')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 1.0
    end
  end
end

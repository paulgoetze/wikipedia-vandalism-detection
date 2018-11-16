require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::PronounImpact do
  it { is_expected.to be_a Features::ImpactBase }

  describe '#calculate' do
    it 'returns the impact of pronouns of the new revision text' do
      # 3 pronouns
      old_text = Text.new('Your old text will be mine or Your’s')

      # 4 pronouns
      new_text = Text.new('My new text and your old text will be ours and mine')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 3.0 / (3.0 + 4.0)
    end

    it 'returns 0.5 if both text revisions include no terms' do
      text = Text.new('{{speedy deletion}}')

      old_rev = build(:old_revision, text: text)
      new_rev = build(:new_revision, text: text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.5
    end

    it 'returns 0.0 for emtpy clean text of old revision' do
      old_text = Text.new('{{speedy deletion}}')
      new_text = Text.new('You')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end

    it 'returns 1.0 for emtpy clean text of new revision' do
      old_text = Text.new('You')
      new_text = Text.new('{{speedy deletion}}')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 1.0
    end
  end
end

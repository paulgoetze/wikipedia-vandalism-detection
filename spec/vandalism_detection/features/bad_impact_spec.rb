require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::BadImpact do
  it { is_expected.to be_a Features::ImpactBase }

  describe '#calculate' do
    it 'returns the impact of bad words of the edit’s new revision text' do
      # 3 bad words
      old_text = Text.new('Hi, old text 666, dont know')

      # 4 bad words
      new_text = Text.new('Hi, new text dosent, whatever, guy')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 3.0 / (3.0 + 4.0)
    end

    it 'returns 0.5 on both no terms in text revisions' do
      text = Text.new('{speedy deletion}}')

      old_rev = build(:old_revision, text: text)
      new_rev = build(:new_revision, text: text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.5
    end

    it 'returns 0.0 on emtpy clean text of old revision' do
      old_text = Text.new('{{speedy deletion}}')
      new_text = Text.new('Guy')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end

    it 'returns 1.0 on emtpy clean text of new revision' do
      old_text = Text.new('Guy')
      new_text = Text.new('{{speedy deletion}}')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 1.0
    end
  end
end

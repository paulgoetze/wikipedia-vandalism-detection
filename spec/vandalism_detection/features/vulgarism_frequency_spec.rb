require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::VulgarismFrequency do
  it { is_expected.to be_a Features::FrequencyBase }

  describe '#calculate' do
    it 'returns the number of vulgarism words over all inserted words' do
      # total 8 inserted words, 3 vulgarism
      old_text = Text.new('Old shit.')
      new_text = Text.new('Old shit. Fuck, fu*ck you $lut, and all the others.')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 3.0 / 8.0
    end

    it 'returns 0.0 on emtpy clean text revisions' do
      old_text = Text.new('Old shit.')
      new_text = Text.new('Old shit. {{speedy deletion}}')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

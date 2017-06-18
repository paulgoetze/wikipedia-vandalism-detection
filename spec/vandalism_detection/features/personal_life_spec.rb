require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::PersonalLife do
  it { is_expected.to be_a Features::ContainsBase }

  describe '#calculate' do
    it 'returns 1 if the edit comment includes "personal life"' do
      comment = Text.new('/* Personal life */ edited')
      new_rev = build(:new_revision, comment: comment)
      edit = build(:edit, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 1
    end

    it 'returns 0 on emtpy comment' do
      new_rev = build(:new_revision, comment: '')
      edit = build(:edit, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0
    end
  end
end

require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::Copyedit do
  it { is_expected.to be_a Features::ContainsBase }

  describe '#calculate' do
    it 'returns 1 if the edit comment includes "copyedit"' do
      comment = Text.new('copyediting content')
      new_rev = build(:new_revision, comment: comment)
      edit = build(:edit, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 1
    end

    it 'returns 1 if the edit comment includes "copy edit"' do
      comment = Text.new('copy editing content')
      new_rev = build(:new_revision, comment: comment)
      edit = build(:edit, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 1
    end

    it 'returns 0 for emtpy an comment in new revision' do
      new_rev = build(:new_revision, comment: '')
      edit = build :edit, new_revision: new_rev

      expect(subject.calculate(edit)).to eq 0
    end
  end
end

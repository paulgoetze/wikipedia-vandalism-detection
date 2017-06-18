require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::Reverted do
  it { is_expected.to be_a Features::ContainsBase }

  describe '#calculate' do
    %w[rvt rvv revert].each do |term|
      it "returns 1 if the edit comment includes '#{term}'" do
        comment = Text.new("#{term} edited")
        new_rev = build(:new_revision, comment: comment)
        edit = build(:edit, new_revision: new_rev)

        expect(subject.calculate(edit)).to eq 1
      end
    end

    it 'returns 0 for an emtpy comment' do
      new_rev = build(:new_revision, comment: '')
      edit = build(:edit, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0
    end
  end
end

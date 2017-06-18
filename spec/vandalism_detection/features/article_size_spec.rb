require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::ArticleSize do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the size of the edit’s new revisions' do
      old_rev_text = Text.new('123')
      new_rev_text = Text.new('123 456789') # size 10 (with spaces)

      old_rev = build(:old_revision, text: old_rev_text)
      new_rev = build(:new_revision, text: new_rev_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 10
    end

    it "returns 0 if the edit's new revisions is empty" do
      old_rev_text = Text.new('123')
      new_rev_text = Text.new # size 0

      old_rev = build(:old_revision, text: old_rev_text)
      new_rev = build(:new_revision, text: new_rev_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0
    end
  end
end

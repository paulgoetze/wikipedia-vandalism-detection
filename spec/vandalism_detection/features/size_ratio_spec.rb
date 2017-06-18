require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::SizeRatio do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the ratio of the revisions text sizes' do
      old_text = Text.new('123456789') # length 9
      new_text = Text.new('123') # length 3

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 9.0 / (9.0 + 3.0)
    end

    it 'returns 1.0 for an emtpy text in the new revision' do
      old_text = Text.new('sample text')
      new_text = Text.new

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 1.0
    end

    it 'returns 0.0 for an emtpy text in the old revisions' do
      old_text = Text.new
      new_text = Text.new('sample text')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end

    it 'returns 0.5 if both revision texts are empty' do
      old_rev = build(:old_revision, text: Text.new)
      new_rev = build(:new_revision, text: Text.new)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.5
    end
  end
end

require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::InsertedInternalLinks do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the number of inserted internal links' do
      old_text = Text.new('123')
      new_text = Text.new('123 [[link]] [[linkname|link]]')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 2
    end

    it 'returns 0 if no inserted text' do
      old_text = Text.new('123 456789')
      new_text = Text.new('123') # 0 inserted

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0
    end
  end
end

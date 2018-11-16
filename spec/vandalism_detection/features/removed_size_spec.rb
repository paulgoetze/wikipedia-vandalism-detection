require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RemovedSize do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the size of the new removed text' do
      old_text = Text.new('123 456789')
      new_text = Text.new('123') # 6 removed

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 6
    end

    it 'returns 0 if no removed text ' do
      old_text = Text.new('123')
      new_text = Text.new('123 456789') # 0 removed

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0
    end
  end
end

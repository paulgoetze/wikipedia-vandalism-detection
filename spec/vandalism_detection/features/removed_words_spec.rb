require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::RemovedWords do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the number of the edit’s removed words' do
      old_text = Text.new('zero one two three four five six') # 6 removed
      new_text = Text.new('zero')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 6
    end

    it 'returns 0 if no text was removed' do
      old_text = Text.new('zero') # 0 removed
      new_text = Text.new('zero one')

      old_rev = build(:old_revision, text: old_text)
      new_rev = build(:new_revision, text: new_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 0
    end
  end
end

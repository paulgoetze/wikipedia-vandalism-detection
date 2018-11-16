require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::SizeIncrement do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns a negative increment on more removed texts' do
      old_rev_text = Text.new('123456789') # length 9
      new_rev_text = Text.new('123') # length 3

      old_rev = build(:old_revision, text: old_rev_text)
      new_rev = build(:new_revision, text: new_rev_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 3.0 - 9.0
    end

    it 'returns a positive increment on more removed texts' do
      old_rev_text = Text.new('123') # length 3
      new_rev_text = Text.new('123456789') # length 9

      old_rev = build(:old_revision, text: old_rev_text)
      new_rev = build(:new_revision, text: new_rev_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 9.0 - 3.0
    end
  end
end

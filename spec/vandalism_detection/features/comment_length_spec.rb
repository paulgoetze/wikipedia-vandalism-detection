require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::CommentLength do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns the length of the new revisions comment' do
      comment = Text.new('1 34567 9')
      edit = build :edit, new_revision: build(:new_revision, comment: comment)

      expect(subject.calculate(edit)).to eq 9
    end

    it 'returns 0 on emtpy clean text' do
      text = Text.new('{{speedy deletion}}')
      edit = build :edit, new_revision: build(:new_revision, text: text)

      expect(subject.calculate(edit)).to eq 0
    end
  end
end

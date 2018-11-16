require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::Blanking do
  let(:blank_text) { 'a' * (Features::Blanking::BLANKING_THRESHOLD - 1) }

  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'returns 1.0 in case of full blanking the new revision' do
      # full blanking means size < BLANKING_THRESHOLD.
      old_rev = build(:old_revision, text: "#{blank_text} additional text")
      new_rev = build(:new_revision, text: blank_text)
      edit = build(:edit, old_revision: old_rev, new_revision: new_rev)

      expect(subject.calculate(edit)).to eq 1.0
    end

    it 'returns 0.0 in case of not full blanking the new revision' do
      # not full blanking means size > BLANKING_THRESHOLD.
      old_rev = build(:old_revision, text: "#{blank_text} additional text")
      new_rev = build(:new_revision, text: "#{blank_text}a")
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end

    it 'returns 0.0 if old revision is <= new revision' do
      old_rev = build(:old_revision, text: blank_text)
      new_rev = build(:new_revision, text: blank_text.next!)
      edit = build(:edit, new_revision: new_rev, old_revision: old_rev)

      expect(subject.calculate(edit)).to eq 0.0
    end
  end
end

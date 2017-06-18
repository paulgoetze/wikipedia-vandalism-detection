require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::Anonymity do
  it { is_expected.to be_a Features::Base }

  describe '#calculate' do
    it 'return 1.0 in case of an registered editor' do
      edit = build :edit, new_revision: build(:registered_revision)
      expect(subject.calculate(edit)).to eq 1
    end

    it 'returns 0.0 in case of an anonymous editor' do
      edit = build :edit, new_revision: build(:anonymous_revision)
      expect(subject.calculate(edit)).to eq 0
    end
  end
end

require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::FrequencyBase do
  let(:terms) { Wikipedia::VandalismDetection::WordLists::PRONOUNS }

  it { is_expected.to be_a Features::Base }

  describe '#frequency' do
    it { is_expected.to respond_to :frequency }

    it 'returns the frequency in percentage of given word counts' do
      text = 'I am, i like you.'
      expect(subject.frequency(text, terms)).to eq 3.0 / 5.0
    end

    it 'returns 0.0 if total word count is zero' do
      expect(subject.frequency('', terms)).to eq 0.0
    end
  end
end

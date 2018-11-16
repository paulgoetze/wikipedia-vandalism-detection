require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::ContainsBase do
  it { is_expected.to be_a Features::Base }

  describe '#contains' do
    it 'returns 1 if a given text contains the given terms array' do
      text = 'Content including text'
      expect(subject.contains(text, %w[content anything])).to eq 1
    end

    it 'returns 1 if a given text contains the given string' do
      text = 'Content including text'
      expect(subject.contains(text, 'content')).to eq 1
    end

    it 'returns 0 if a given text does not contain the given string' do
      text = 'not containing anything con tent'
      expect(subject.contains(text, 'content')).to eq 0
    end

    it 'returns 0 if a given text does not contain any of the given terms' do
      text = 'not containing anything con tent'
      expect(subject.contains(text, %w[content text])).to eq 0
    end
  end
end

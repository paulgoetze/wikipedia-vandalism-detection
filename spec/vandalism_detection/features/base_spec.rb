require 'spec_helper'

describe Wikipedia::VandalismDetection::Features::Base do
  describe '#count' do
    let(:text) { 'I,  you: i will help You' }

    it { should respond_to(:count).with(2).arguments }

    it 'raises an error if option :in is not defined' do
      expect { subject.count(%i[i you], from: text) }
        .to raise_error ArgumentError
    end

    it 'raises an error if terms is not an Array or String' do
      expect { subject.count({ term: 'You' }, in: text) }
        .to raise_error ArgumentError
    end

    it 'returns the total number of terms found for the given terms array' do
      terms = %i[i you]
      expect(subject.count(terms, in: text)).to eq 4
    end

    it 'returns the number of terms found for the given single term' do
      expect(subject.count('You', in: text)).to eq 2
    end
  end

  describe '#calculate' do
    it { should respond_to :calculate }

    it 'takes an Wikipedia::Edit as argument' do
      edit = build(:edit)
      expect { subject.calculate(edit) }.not_to raise_error
    end

    it 'raises an ArgumentError if argument is no Wikipedia::Edit' do
      expect { subject.calculate('string') }.to raise_error
    end
  end
end

require 'spec_helper'

describe Wikipedia::VandalismDetection::Algorithms::KullbackLeiblerDivergence do
  it { is_expected.to respond_to :of }

  describe '#of' do
    it 'returns missing value if no character in either of the texts' do
      expect(subject.of('&', '?')).to eq Features::MISSING_VALUE
    end

    it 'returns zero for equal texts' do
      text = 'Text sample'
      expect(subject.of(text, text)).to eq 0.0
    end

    it 'returns a value bigger than zero for different texts' do
      expect(subject.of('Text 1', 'Text 2')).to be > 0.0
    end

    it 'returns a higher value for a more different text' do
      lower_divergence = subject.of('text a', 'text b')
      higher_divergence = subject.of('text a', 'bla bla bla')

      expect(lower_divergence).to be < higher_divergence
    end

    it 'can handle invalid byte sequences' do
      invalid_byte_sequence = "text \255".force_encoding('UTF-8')
      expect { subject.of(invalid_byte_sequence, invalid_byte_sequence) }
        .not_to raise_error
    end
  end
end

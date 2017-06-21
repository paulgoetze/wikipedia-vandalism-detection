require 'spec_helper'

describe Text do
  it { is_expected.to be_a String }
  it { is_expected.to respond_to :clean }

  describe '#initialze' do
    it 'removes invalid byte sequences' do
      text = Text.new("text \255".force_encoding('UTF-8'))
      expect(text).to eq 'text '
    end
  end

  describe '#clean' do
    it 'raises an WikitextExtractionError if text cannot be parsed' do
      text = Text.new("[[Image:img.jpg|\n{|\n|-\n|||| |}")

      expect { text.clean }.to raise_error \
        Wikipedia::VandalismDetection::WikitextExtractionError
    end

    it 'returns the text cleaned from wiki tags' do
      wiki_text = Text.new(load_file('sample_revision.txt'))
      clean_text = load_file('sample_revision_clean_text.txt')

      expect(wiki_text.clean).to eq clean_text
    end
  end
end

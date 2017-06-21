require 'spec_helper'

describe Wikipedia::VandalismDetection::Diff do
  let(:old_text) { Text.new("hello\nworld\nmy name is Luke\n") }
  let(:new_text) { Text.new("world\nhello\nmy name is Mr. Skywalker\n") }
  let(:diff) { Wikipedia::VandalismDetection::Diff.new(old_text, new_text) }

  it 'can deal with invalid byte sequences' do
    text = "text \255".force_encoding('UTF-8')
    diff = Wikipedia::VandalismDetection::Diff.new("#{text} a", "#{text} b")

    expect(diff).to be_a Wikipedia::VandalismDetection::Diff
  end

  describe '#inserted_words' do
    let(:words) { diff.inserted_words }

    it 'returns the inserted words as array' do
      expect(words).to be_an Array
      expect(words.count).to eq 3
    end

    it 'returns the right inserted words' do
      expect(words).to eq %w[hello Mr. Skywalker]
    end
  end

  describe '#removed_words' do
    let(:words) { diff.removed_words }

    it 'returns the removed words as array' do
      expect(words).to be_an Array
      expect(words.count).to eq 2
    end

    it 'returns the right removed words' do
      expect(words).to eq %w[hello Luke]
    end
  end
end

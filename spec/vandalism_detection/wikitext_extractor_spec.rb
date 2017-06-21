require 'spec_helper'

describe  Wikipedia::VandalismDetection::WikitextExtractor do
  subject { Wikipedia::VandalismDetection::WikitextExtractor }

  describe '.extract' do
    it 'can handle invalid byte sequences' do
      wiki_text = "text \255".force_encoding('UTF-8')
      extracted_text = subject.extract(wiki_text)

      expect(extracted_text).to eq 'text'
    end

    it 'returns an empty string if all the markup is extracted' do
      wiki_text = '{{speedy deletion}}'
      extracted_text = subject.extract(wiki_text)

      expect(extracted_text).to be_empty
    end

    it 'removes #REDIRECT markup' do
      wiki_text = '#REDIRECT [[Heading]]'
      plain_text = 'Heading'
      extracted_text = subject.extract(wiki_text)

      expect(extracted_text).to eq plain_text
    end

    it 'can extract plaintext from wikitext' do
      wiki_text = load_file('sample_revision.txt')
      plain_text = load_file('sample_revision_plain_text.txt')
      extracted_text = subject.extract(wiki_text)

      expect(extracted_text << "\n").to eq plain_text
    end

    it 'raises a WikitextExtractionError when extracting unparsable text' do
      unparsable_wiki_text = "[[Image:img.jpg|\n{|\n|-\n|||| |}"

      expect { subject.extract(unparsable_wiki_text) }
        .to raise_error Wikipedia::VandalismDetection::WikitextExtractionError
    end
  end

  describe '.extract_clean' do
    it 'can extract full cleaned text from wikitext' do
      wiki_text = load_file('sample_revision.txt')
      clean_text = load_file('sample_revision_clean_text.txt')
      extracted_text = subject.extract_clean(wiki_text)

      expect(extracted_text).to eq clean_text
    end

    it 'removes section numbering while cleaning wikitext' do
      wiki_text = "1.1. header 1\n\n1.2. header 2"
      clean_text = 'header 1 header 2'
      extracted_text = subject.extract_clean(wiki_text)

      expect(extracted_text).to eq clean_text
    end

    it 'removes line breaks while cleaning wikitext' do
      wiki_text = "line 1\n\nline 2\nline 3"
      clean_text = 'line 1 line 2 line 3'
      extracted_text = subject.extract_clean(wiki_text)

      expect(extracted_text).to eq clean_text
    end

    it 'removes multiple spaces while cleaning wikitext' do
      wiki_text = "line    1  \n\nline   2   \nline       3   "
      clean_text = 'line 1 line 2 line 3'
      extracted_text = subject.extract_clean(wiki_text)

      expect(extracted_text).to eq clean_text
    end

    it 'removes links from text while cleaning wikitext' do
      wiki_text = "A link\nis here http://example.com/image.jpg not\nanymore." \
                  "\n==Reference==\n" \
                  '*[http://www.itis.usda.gov/servlet/SingleRpt/SingleRpt?' \
                  'search_topic=TSN&amp;search_value=180211 ITIS 180211] 2002-12-14'

      clean_text = 'A link is here not anymore. Reference ITIS 180211 2002-12-14'
      extracted_text = subject.extract_clean(wiki_text)

      expect(extracted_text).to eq clean_text
    end

    it 'raises a WikitextExtractionError while extracting unparsable text' do
      unparsable_wiki_text = "[[Image:img.jpg|\n{|\n|-\n|||| |}"

      expect { subject.extract_clean(unparsable_wiki_text) }
        .to raise_error Wikipedia::VandalismDetection::WikitextExtractionError
    end
  end
end

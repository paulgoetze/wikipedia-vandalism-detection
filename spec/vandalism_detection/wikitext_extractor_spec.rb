require 'spec_helper'

describe  Wikipedia::VandalismDetection::WikitextExtractor do

  it "returns an empty string if the all the markup is extracted" do
    wiki_text = "{{speedy deletion}}"

    Wikipedia::VandalismDetection::WikitextExtractor.extract(wiki_text).should == ""
  end

  it "removes #REDIRECT markup" do
    wiki_text = "#REDIRECT [[Heading]]"
    plain_text = "Heading"

    Wikipedia::VandalismDetection::WikitextExtractor.extract(wiki_text).should == plain_text
  end

  it "can extract plaintext from wikitext" do
    wiki_text = load_file('sample_revision.txt')
    plain_text = load_file('sample_revision_plain_text.txt')

    Wikipedia::VandalismDetection::WikitextExtractor.extract(wiki_text).should == plain_text
  end

  it "can extract full cleaned text from wikitext" do
    wiki_text = load_file('sample_revision.txt')
    clean_text = load_file('sample_revision_clean_text.txt')

    Wikipedia::VandalismDetection::WikitextExtractor.extract_clean(wiki_text).should == clean_text
  end

  it "removes section numbering while cleaning wikitext" do
    wiki_text = "1.1. header 1\n\n1.2. header 2"
    clean_text = "header 1 header 2"
    Wikipedia::VandalismDetection::WikitextExtractor.extract_clean(wiki_text).should == clean_text
  end

  it "removes line breaks while cleaning wikitext" do
    wiki_text = "line 1\n\nline 2\nline 3"
    clean_text = "line 1 line 2 line 3"
    Wikipedia::VandalismDetection::WikitextExtractor.extract_clean(wiki_text).should == clean_text
  end

  it "removes multiple spaces while cleaning wikitext" do
    wiki_text = "line    1  \n\nline   2   \nline       3   "
    clean_text = "line 1 line 2 line 3"
    Wikipedia::VandalismDetection::WikitextExtractor.extract_clean(wiki_text).should == clean_text
  end

  it "removes links from text while cleaning wikitext" do
    wiki_text = "A link\nis here http://example.com/image.jpg not\nanymore." <<
    "\n==Reference==\n" <<
    "*[http://www.itis.usda.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&amp;search_value=180211 ITIS 180211] 2002-12-14"
    clean_text = "A link is here not anymore. Reference ITIS 180211 2002-12-14"

    Wikipedia::VandalismDetection::WikitextExtractor.extract_clean(wiki_text).should == clean_text
  end

  it "raises a WikitextExtractionError while extracting unparsable wikitext" do
    unparsable_wiki_text = "[[Image:img.jpg|\n{|\n|-\n|||| |}"
    expect {  Wikipedia::VandalismDetection::WikitextExtractor.extract(unparsable_wiki_text) }.to raise_error
  end

end
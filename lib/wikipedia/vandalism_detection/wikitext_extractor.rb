# The WikitextExtractor imports the WikitextExtractor class from the sweble-wikitext-extractor.jar
# The sweble-wikitext-extractor.jar is a custom Java project which uses the Sweble wikitext parser to extract
# plaintext out of wikimarkup text.
#
# The Sweble WikitextExtractor currently depends on the swc-engine -v1.1.0 with dependencies,
# see: http://sweble.org/downloads/swc-devel/master-latest/ to download it.
#
# The Java source code can be found on:
# webis.uni-weimar.de:/srv/cvsroot/code-in-progress/wikipedia-vandalism-detection/sweble-wikitext-extractor
#
# @author Paul Götze <paul.christoph.goetze@gmail.com>
module Wikipedia
  module VandalismDetection

    require 'java'
    require 'java/swc-engine-1.1.0-jar-with-dependencies.jar'
    require 'java/sweble-wikitext-extractor.jar'

    java_import 'de.webis.sweble.WikitextExtractor'

    class WikitextExtractionError < StandardError; end

    # This class wrapps the de.webis.sweble.WikitextExtractor Java class and provides methods to extract plaintext
    # from wiki markup text both space preserving and cleaned without line breaks and whitespace.
    #
    # @author Paul Götze <paul.christoph.goetze@gmail.com>
    class WikitextExtractor

      REDIRECT = '#REDIRECT'

      # Returns the extracted text from the given wiki markup preserving spacing with added section numbers.
      def self.extract(wiki_text)
        begin
          wiki_text = wiki_text.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
          wiki_text = wiki_text.gsub(REDIRECT, '')

          WikitextExtractor.new.extract(wiki_text)
        rescue => exception
          raise WikitextExtractionError, "Wikitext extraction failed: \n#{exception.message}", caller
        end
      end

      # Returns the cleaned extracted text from the given wiki markup.
      # Cleaned means a single string without breaks, multiple spaces and section numbers.
      def self.extract_clean(wiki_text)
        wiki_text = extract wiki_text

        wiki_text = remove_section_numbering_from wiki_text
        wiki_text = remove_line_breaks_from wiki_text
        wiki_text = remove_uris_from wiki_text
        wiki_text = remove_special_signes_from wiki_text
        wiki_text = remove_multiple_spaces_from wiki_text
        wiki_text = wiki_text.strip
      end

      private

      # removes 1., 1.1., 2.3.4. etc. at the beginning of a line
      def self.remove_section_numbering_from(text)
        text.gsub /^(\d\.)+/, ''
      end

      def self.remove_line_breaks_from(text)
        text.gsub /\n+/, ' '
      end

      def self.remove_multiple_spaces_from(text)
        text.gsub /\s+/, ' '
      end

      def self.remove_uris_from(text)
        text.gsub /(https?|ftp)\s?:\s?\/\/[^\s\/$.?#].[^\s]*/i, ''
      end

      def self.remove_special_signes_from(text)
        text.gsub /\[\]\{\}\|\=/, ' '
      end
    end
  end
end
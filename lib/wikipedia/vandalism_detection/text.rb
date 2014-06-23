require 'wikipedia/vandalism_detection/wikitext_extractor'

module Wikipedia
  module VandalismDetection
    class Text < String

      def initialize(text = "")
        super text.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
      end

      # Extracts the plaintext from mediawiki markup and removes all line breaks & multiple spaces
      # Return the cleaned plaintext.
      def clean
        @clean ||= WikitextExtractor.extract_clean self
      end
    end
  end
end
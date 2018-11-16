require 'wikipedia/vandalism_detection/features/base'
require 'wikipedia/vandalism_detection/word_lists/markup'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes frequency of bad words in the inserted text.
      class MarkupFrequency < Base
        MARKUP_REGEX = /(#{WordLists::MARKUP.join('|')})/

        # Returns the percentage of markup related words in the inserted text.
        # Returns 0.0 if inserted clean text is of zero length.
        def calculate(edit)
          super

          text = edit.inserted_text
          all_words_count = edit.inserted_words.count
          markup_words_count = text.scan(MARKUP_REGEX).count

          if all_words_count > 0
            markup_words_count.to_f / all_words_count.to_f
          else
            0.0
          end
        end
      end
    end
  end
end

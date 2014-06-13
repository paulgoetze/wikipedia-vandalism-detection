require 'wikipedia/vandalism_detection/features/base'
require 'wikipedia/vandalism_detection/word_lists/markup'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes frequency of bad words in the inserted text.
      class MarkupFrequency < Base

        # Returns the percentage of markup related words in the inserted text.
        # Returns 0.0 if inserted clean text is of zero length.
        def calculate(edit)
          super

          text = edit.inserted_text
          all_words_count = edit.inserted_words.count

          regex = /(#{WordLists::MARKUP.join('|')})/
          markup_words_count = text.scan(regex).count

          (all_words_count > 0) ? (markup_words_count.to_f) / (all_words_count.to_f) : 0.0
        end
      end
    end
  end
end
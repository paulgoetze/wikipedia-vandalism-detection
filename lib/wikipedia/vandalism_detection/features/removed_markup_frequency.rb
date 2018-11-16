require 'wikipedia/vandalism_detection/features/base'
require 'wikipedia/vandalism_detection/word_lists/markup'
require 'wikipedia/vandalism_detection/text'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes the frequency of markup words in the removed text.
      class RemovedMarkupFrequency < Base
        MARKUP_REGEX = /(#{WordLists::MARKUP.join('|')})/

        # Returns the percentage of markup words in the removed text.
        # Returns 0.0 if cleaned removed text is of zero length.
        def calculate(edit)
          super

          text = edit.removed_text
          all_words_count = edit.removed_words.count
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

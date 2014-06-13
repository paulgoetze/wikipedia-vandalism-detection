require 'wikipedia/vandalism_detection/features/frequency_base'
require 'wikipedia/vandalism_detection/word_lists/sex'
require 'wikipedia/vandalism_detection/text'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the frequency of markup words in the removed text.
      class RemovedMarkupFrequency < Base

        # Returns the percentage of markup words in the removed text.
        # Returns 0.0 if cleaned removed text is of zero length.
        def calculate(edit)
          super

          text = edit.removed_text
          all_words_count = edit.removed_words.count

          regex = /(#{WordLists::MARKUP.join('|')})/
          markup_words_count = text.scan(regex).count

          (all_words_count > 0) ? (markup_words_count.to_f) / (all_words_count.to_f) : 0.0
        end
      end
    end
  end
end
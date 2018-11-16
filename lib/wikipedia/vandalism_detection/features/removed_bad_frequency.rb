require 'wikipedia/vandalism_detection/features/frequency_base'
require 'wikipedia/vandalism_detection/word_lists/sex'
require 'wikipedia/vandalism_detection/text'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes the frequency of bad words in the removed text.
      class RemovedBadFrequency < FrequencyBase
        # Returns the percentage of bad words in the removed text.
        # Returns 0.0 if cleaned removed text is of zero length.
        def calculate(edit)
          super

          text = Text.new(edit.removed_words.join("\n")).clean
          frequency(text, WordLists::BAD)
        end
      end
    end
  end
end

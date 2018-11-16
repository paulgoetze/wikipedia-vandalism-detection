require 'wikipedia/vandalism_detection/features/frequency_base'
require 'wikipedia/vandalism_detection/word_lists/biased'
require 'wikipedia/vandalism_detection/text'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes frequency of biased words in the removed text.
      class RemovedBiasedFrequency < FrequencyBase
        # Returns the percentage of biased words in the removed text.
        # Returns 0.0 if removed clean text is of zero length.
        def calculate(edit)
          super

          text = Text.new(edit.removed_words.join("\n")).clean
          frequency(text, WordLists::BIASED)
        end
      end
    end
  end
end

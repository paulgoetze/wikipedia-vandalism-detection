require 'wikipedia/vandalism_detection/features/frequency_base'
require 'wikipedia/vandalism_detection/word_lists/bad'
require 'wikipedia/vandalism_detection/text'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes frequency of bad words in the inserted text.
      class BadFrequency < FrequencyBase
        # Returns the percentage of bad words in the inserted text.
        # Returns 0.0 if inserted clean text is of zero length.
        def calculate(edit)
          super

          text = Text.new(edit.inserted_words.join("\n")).clean
          frequency(text, WordLists::BAD)
        end
      end
    end
  end
end

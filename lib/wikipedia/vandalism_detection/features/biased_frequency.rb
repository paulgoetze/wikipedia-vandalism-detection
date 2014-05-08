require 'wikipedia/vandalism_detection/features/frequency_base'
require 'wikipedia/vandalism_detection/word_lists/biased'
require 'wikipedia/vandalism_detection/text'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes frequency of biased words in the inserted text.
      class BiasedFrequency < FrequencyBase

        # Returns the percentage of biased words in the inserted text.
        # Returns 0.0 if inserted clean text is of zero length.
        def calculate(edit)
          super

          text = Text.new(edit.inserted_words.join("\n")).clean
          frequency(text, WordLists::BIASED)
        end
      end
    end
  end
end
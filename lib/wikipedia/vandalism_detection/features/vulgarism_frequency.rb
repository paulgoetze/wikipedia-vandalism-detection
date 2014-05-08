require 'wikipedia/vandalism_detection/features/frequency_base'
require 'wikipedia/vandalism_detection/word_lists/vulgarism'
require 'wikipedia/vandalism_detection/text'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes frequency of vulgarism words in the inserted text.
      class VulgarismFrequency < FrequencyBase

        # Returns the percentage of vulgarism words in the inserted text.
        # Returns 0.0 if inserted clean text is of zero length.
        def calculate(edit)
          super

          text = Text.new(edit.inserted_words.join("\n")).clean
          frequency(text, WordLists::VULGARISM)
        end
      end
    end
  end
end
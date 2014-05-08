require 'wikipedia/vandalism_detection/features/frequency_base'
require 'wikipedia/vandalism_detection/word_lists/vulgarism'
require 'wikipedia/vandalism_detection/text'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes frequency of vulgarism words in the removed text.
      class RemovedVulgarismFrequency < FrequencyBase

        # Returns the percentage of vulgarism words in the removed text.
        # Returns 0.0 if removed clean text is of zero length.
        def calculate(edit)
          super

          text = Text.new(edit.removed_words.join("\n")).clean
          frequency(text, WordLists::VULGARISM)
        end
      end
    end
  end
end
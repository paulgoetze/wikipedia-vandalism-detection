require 'wikipedia/vandalism_detection/features/frequency_base'
require 'wikipedia/vandalism_detection/word_lists'
require 'wikipedia/vandalism_detection/text'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes frequency of all wordlists words in the text of the edit's new revision.
      class AllWordlistsFrequency < FrequencyBase

        # Returns the percentage of wordlists words in the new revision's text.
        # Returns 0.0 if text is of zero length.
        def calculate(edit)
          super

          text = Text.new(edit.inserted_words.join("\n")).clean
          frequency(text, WordLists.all)
        end
      end
    end
  end
end
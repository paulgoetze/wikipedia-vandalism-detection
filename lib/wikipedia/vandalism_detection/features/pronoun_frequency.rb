require 'wikipedia/vandalism_detection/features/frequency_base'
require 'wikipedia/vandalism_detection/word_lists/pronouns'
require 'wikipedia/vandalism_detection/text'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes the frequency of pronouns in the insetred text.
      class PronounFrequency < FrequencyBase
        # Returns the percentage of pronoun words in the inserted text.
        # Returns 0.0 if inserted clean text is of zero length.
        def calculate(edit)
          super

          text = Text.new(edit.inserted_words.join("\n")).clean
          frequency(text, WordLists::PRONOUNS)
        end
      end
    end
  end
end

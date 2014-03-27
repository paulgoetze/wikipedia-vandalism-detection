require 'wikipedia/vandalism_detection/features/frequency_base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes frequency of vulgarism words in the text of the edit's new revision.
      class VulgarismFrequency < FrequencyBase

        # Returns the percentage of vulgarism words in the new revision's text.
        # Returns 0.0 if text is of zero length.
        def calculate(edit)
          super

          text = edit.new_revision.text.clean
          frequency(text, WordLists::VULGARISM)
        end
      end
    end
  end
end
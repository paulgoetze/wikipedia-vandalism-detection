require 'wikipedia/vandalism_detection/features/frequency_base'
require 'wikipedia/vandalism_detection/word_lists/biased'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes frequency of biased words in the comment of the edit's new revision.
      class CommentBiasedFrequency < FrequencyBase

        # Returns the percentage of biased words in the new revision's comment.
        # Returns 0.0 if text is of zero length.
        def calculate(edit)
          super

          comment = edit.new_revision.comment.clean
          frequency(comment, WordLists::BIASED)
        end
      end
    end
  end
end
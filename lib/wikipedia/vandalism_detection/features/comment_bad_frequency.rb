require 'wikipedia/vandalism_detection/features/frequency_base'
require 'wikipedia/vandalism_detection/word_lists/bad'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes frequency of bad words in the comment of the edit's new revision.
      class CommentBadFrequency < FrequencyBase

        # Returns the percentage of bad words in the new revision's comment.
        # Returns 0.0 if text is of zero length.
        def calculate(edit)
          super

          comment = edit.new_revision.comment.clean
          frequency(comment, WordLists::BAD)
        end
      end
    end
  end
end
require 'wikipedia/vandalism_detection/features/frequency_base'
require 'wikipedia/vandalism_detection/word_lists/sex'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes frequency of sex words in the comment of the
      # edit's new revision.
      class CommentSexFrequency < FrequencyBase
        # Returns the percentage of sex words in the new revision's comment.
        # Returns 0.0 if text is of zero length.
        def calculate(edit)
          super

          comment = edit.new_revision.comment.clean
          frequency(comment, WordLists::SEX)
        end
      end
    end
  end
end

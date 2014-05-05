require 'wikipedia/vandalism_detection/features/frequency_base'
require 'wikipedia/vandalism_detection/word_lists/pronouns'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the frequency of pronouns in the comment of the new revision.
      class CommentPronounFrequency < FrequencyBase

        # Returns the percentage of pronoun words in the new revision's comment.
        # Returns 0.0 if text is of zero length.
        def calculate(edit)
          super

          comment = edit.new_revision.comment.clean
          frequency(comment, WordLists::PRONOUNS)
        end
      end
    end
  end
end
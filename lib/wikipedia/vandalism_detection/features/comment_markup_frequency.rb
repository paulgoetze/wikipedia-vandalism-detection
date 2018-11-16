require 'wikipedia/vandalism_detection/features/base'
require 'wikipedia/vandalism_detection/word_lists/markup'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes frequency of markup words in the comment of the
      # edit's new revision.
      class CommentMarkupFrequency < Base
        MARKUP_REGEX = /(#{WordLists::MARKUP.join('|')})/

        # Returns the percentage of markup words in the new revision's comment.
        # Returns 0.0 if text is of zero length.
        def calculate(edit)
          super

          comment = edit.new_revision.comment
          all_words_count = comment.split.count
          markup_words_count = comment.scan(MARKUP_REGEX).count

          if all_words_count > 0
            markup_words_count.to_f / all_words_count.to_f
          else
            0.0
          end
        end
      end
    end
  end
end

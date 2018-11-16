require 'wikipedia/vandalism_detection/features/base'
require 'wikipedia/vandalism_detection/word_lists/emoticons'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes the frequency of emoticon words in the removed
      # text.
      class RemovedEmoticonsFrequency < Base
        # Returns the percentage of markup words in the removed text.
        # Returns 0.0 if cleaned removed text is of zero length.
        def calculate(edit)
          super

          removed_text = edit.removed_text
          emojis = WordLists::EMOTICONS.join('|')
          regex = /(^|\s)(#{emojis})(?=\s|$|\Z|[\.,!?]\s|[\.!?]\Z)/

          emoticons_count = removed_text.scan(regex).flatten
            .reject { |c| c.size < 2 }.count
          total_count = removed_text.split.count

          total_count > 0 ? emoticons_count.to_f / total_count.to_f : 0.0
        end
      end
    end
  end
end

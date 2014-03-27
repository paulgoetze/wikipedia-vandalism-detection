require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the length of the longest word in the edit's new revision's text.
      class LongestWord < Base

        def calculate(edit)
          super

          sequence_hash = edit.new_revision.text.clean.split(/[\b\s+,;:]/).group_by(&:length)
          sequence_hash.empty? ? 0 : sequence_hash.max.first
        end
      end
    end
  end
end
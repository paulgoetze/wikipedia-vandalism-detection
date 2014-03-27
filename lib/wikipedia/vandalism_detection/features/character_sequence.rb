require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the length of the longest sequence of the same character
      # in the edit's new revision's text.
      class CharacterSequence < Base

        def calculate(edit)
          super

          sequence_hash = edit.new_revision.text.clean.scan(/((.)\2*)/).group_by{ |s, c| s.length }
          sequence_hash.empty? ? 0 : sequence_hash.max.first
        end
      end
    end
  end
end
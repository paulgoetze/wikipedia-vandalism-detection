require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes the length of the longest sequence of the same
      # character in the inserted text.
      class CharacterSequence < Base
        def calculate(edit)
          super

          sequence_hash = edit.inserted_text.scan(/((.)\2*)/)
          sequence_hash = sequence_hash.group_by { |seq, _| seq.length }
          sequence_hash.empty? ? 0 : sequence_hash.max.first
        end
      end
    end
  end
end

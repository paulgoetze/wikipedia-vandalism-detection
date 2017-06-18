require 'wikipedia/vandalism_detection/features/base'
require 'wikipedia/vandalism_detection/text'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes the length of the longest word in the inserted
      # text.
      class LongestWord < Base
        def calculate(edit)
          super

          sequence_hash = Text.new(edit.inserted_words.join("\n"))
            .clean.split(/[\b\s+,;:]/).group_by(&:length)

          sequence_hash.empty? ? 0 : sequence_hash.max.first
        end
      end
    end
  end
end

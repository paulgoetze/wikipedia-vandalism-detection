require 'wikipedia/vandalism_detection/features/contains_base'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature returns whether the edit's comment includes reverted key
      # words.
      class Reverted < ContainsBase
        def calculate(edit)
          super

          contains(edit.new_revision.comment, %w[rvt rvv revert])
        end
      end
    end
  end
end

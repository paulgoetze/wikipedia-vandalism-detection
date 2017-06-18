require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes the size of removed text in the edit's new revision.
      class RemovedSize < Base
        # Returns the size of removed character in the new revision.
        def calculate(edit)
          super

          size = edit.removed_text.size
          size.positive? ? size : 0
        end
      end
    end
  end
end

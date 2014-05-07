require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the size of inserted text in the edit's new revision.
      class InsertedSize < Base

        # Returns the size of inserted character in the new revision.
        def calculate(edit)
          super

          size = edit.inserted_text.size
          size >= 0 ? size : 0
        end
      end
    end
  end
end
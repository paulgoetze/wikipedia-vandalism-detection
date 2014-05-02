require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the increment of the edit's revisions text length.
      class SizeIncrement < Base

        # Returns the increment of new text length to old text length.
        #	computation: |new| - |old|
        def calculate(edit)
          super

          edit.new_revision.text.size - edit.old_revision.text.size
        end
      end
    end
  end
end
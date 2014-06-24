require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the increment of the edit's revisions text length.
      class SizeIncrement < Base

        #	computation: |new| - |old|
        def calculate(edit)
          super

          old_size = edit.old_revision.text.size
          new_size = edit.new_revision.text.size

          new_size - old_size
        end
      end
    end
  end
end
require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the ratio of the edit's revisions text length.
      class SizeRatio < Base

        # Returns the ration of new text length to old text length:
        # returns 0.0 for empty old revision text,
        # returns 1.0 for empty new revision text,
        # returns 0.5 for both revision texts empty or same size
        #	computation: old / old + new
        def calculate(edit)
          super

          old_size = edit.old_revision.text.size.to_f
          new_size = edit.new_revision.text.size.to_f

          (old_size == 0 && new_size == 0) ? 0.5 : old_size / (old_size + new_size)
        end
      end
    end
  end
end
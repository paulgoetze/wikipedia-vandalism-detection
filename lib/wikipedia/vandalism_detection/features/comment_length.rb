require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the byte length of the edit's new revision's comment.
      class CommentLength < Base

        def calculate(edit)
          super
          edit.new_revision.comment.clean.bytesize
        end
      end
    end
  end
end
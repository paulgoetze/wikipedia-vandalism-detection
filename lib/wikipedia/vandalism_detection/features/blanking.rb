require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature returns whether the edit's is a blanking.
      # size < 7, based on Mola Velasco 2010 implementation.
      class Blanking < Base
        BLANKING_THRESHOLD = 7

        def calculate(edit)
          super

          old_text_size = edit.old_revision.text.size
          new_text_size = edit.new_revision.text.size

          text_removed = old_text_size > new_text_size
          above_threshold = new_text_size < BLANKING_THRESHOLD

          blanking = text_removed && above_threshold
          blanking ? 1.0 : 0.0
        end
      end
    end
  end
end

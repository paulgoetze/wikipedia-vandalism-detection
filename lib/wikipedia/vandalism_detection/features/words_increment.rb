require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the increment of the edit's revisions words.
      class WordsIncrement < Base

        #	computation: |inserted| - |removed|
        def calculate(edit)
          super

          inserted_count = edit.inserted_words.count
          removed_count = edit.removed_words.count

          inserted_count - removed_count
        end
      end
    end
  end
end
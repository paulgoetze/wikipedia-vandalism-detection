require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the number of removed words in the edit's new revision.
      class RemovedWords < Base

        def calculate(edit)
          super

          edit.removed_words.count
        end
      end
    end
  end
end
require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the number of inserted words in the edit's new revision.
      class InsertedWords < Base

        def calculate(edit)
          super

          edit.inserted_words.count
        end
      end
    end
  end
end
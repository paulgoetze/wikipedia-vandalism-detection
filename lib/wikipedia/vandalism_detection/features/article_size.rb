require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the size of the edit's new revision text (article size).
      class ArticleSize < Base

        def calculate(edit)
          super

          edit.new_revision.text.size
        end
      end
    end
  end
end
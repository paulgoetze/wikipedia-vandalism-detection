require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the number of inserted internal links [[link]].
      class InsertedInternalLinks < Base

        def calculate(edit)
          super

          edit.inserted_text.scan(/\[{2}([^\[].*?)\]{2}/).count
        end
      end
    end
  end
end
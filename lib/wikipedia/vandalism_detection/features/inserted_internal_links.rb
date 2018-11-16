require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes the number of inserted internal links [[link]].
      class InsertedInternalLinks < Base
        INTERNAL_LINK_REGEX = /\[{2}([^\[].*?)\]{2}/

        def calculate(edit)
          super

          edit.inserted_text.scan(INTERNAL_LINK_REGEX).count
        end
      end
    end
  end
end

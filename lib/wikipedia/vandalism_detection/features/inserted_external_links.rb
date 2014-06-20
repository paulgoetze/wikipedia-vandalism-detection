require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the number of inserted external links [http://example.com].
      class InsertedExternalLinks < Base

        def calculate(edit)
          super

          edit.inserted_text.scan(/\[?(https?|ftp)\s?:\s?\/\/[^\s\/$.?#].[^\s]*]?/i).count
        end
      end
    end
  end
end
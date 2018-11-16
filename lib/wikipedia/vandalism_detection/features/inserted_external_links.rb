require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes the number of inserted external links of format
      # [http://example.com].
      class InsertedExternalLinks < Base
        URL_REGEX = %r{\[?(https?|ftp)\s?:\s?\/\/[^\s\/$.?#].[^\s]*]?}i

        def calculate(edit)
          super

          edit.inserted_text.scan(URL_REGEX).count
        end
      end
    end
  end
end

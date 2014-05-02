require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the digit to all letters ratio of the edit's new revision inserted text.
      class DigitRatio < Base

        def calculate(edit)
          super

          inserted_letters = edit.inserted_text
          all_letters_count = inserted_letters.scan(/[[:alnum:]]/).size
          digit_count = inserted_letters.scan(/[[:digit:]]/).size

          (1.0 + digit_count) / (1.0 + all_letters_count)
        end
      end
    end
  end
end
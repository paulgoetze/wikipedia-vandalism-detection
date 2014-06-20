require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the digit to all letters ratio of the edit's new revision inserted text.
      class DigitRatio < Base

        def calculate(edit)
          super

          text = edit.inserted_text
          return 0.0 if text.empty?

          all_letters_count = text.scan(/[[:alnum:]]/).size
          digit_count = text.scan(/[[:digit:]]/).size

          digit_count.zero? ? 0.0 : (digit_count.to_f / all_letters_count.to_f)
        end
      end
    end
  end
end
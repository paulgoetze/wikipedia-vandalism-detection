require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes the digit to all letters ratio of the edit's new
      # revision inserted text.
      class DigitRatio < Base
        def calculate(edit)
          super

          text = edit.inserted_text
          return 0.0 if text.empty?

          all_letters_count = text.scan(/[[:alnum:]]/).size
          digit_count = text.scan(/[[:digit:]]/).size

          (1.0 + digit_count) / (1.0 + all_letters_count)
        end
      end
    end
  end
end

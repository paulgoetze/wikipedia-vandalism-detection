require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the non-alphanumeric to all letters ratio of the edit's new revision inserted text.
      class NonAlphanumericRatio < Base

        def calculate(edit)
          super

          text = edit.inserted_text

          puts text
          non_alpha_count = text.scan(/[^a-zA-Z0-9\s]/).size
          all_letters_count = text.scan(/[^\s]/).size

          (1.0 + non_alpha_count) / (1.0 + all_letters_count)
        end
      end
    end
  end
end
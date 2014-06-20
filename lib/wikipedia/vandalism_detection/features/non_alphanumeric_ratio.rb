require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the non-alphanumeric to all letters ratio of the edit's new revision inserted text.
      class NonAlphanumericRatio < Base

        def calculate(edit)
          super

          text = edit.inserted_text
          return 0.0 if text.empty?

          non_alpha_count = text.scan(/[^a-zA-Z0-9\s]/).size
          all_letters_count = text.scan(/[^\s]/).size

          non_alpha_count.zero? ? 0.0 : (non_alpha_count.to_f / all_letters_count.to_f)
        end
      end
    end
  end
end
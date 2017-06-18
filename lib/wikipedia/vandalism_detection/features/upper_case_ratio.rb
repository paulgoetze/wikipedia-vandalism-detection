require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes the uppercase to all letters ratio of the edit's
      # new revision inserted text.
      class UpperCaseRatio < Base
        def calculate(edit)
          super

          text = edit.inserted_text
          return 0.0 if text.empty?

          uppercase_count = text.scan(/[[:upper:]]/).size
          all_letters_count = text.scan(/[[:alpha:]]/).size

          (1.0 + uppercase_count) / (1.0 + all_letters_count)
        end
      end
    end
  end
end

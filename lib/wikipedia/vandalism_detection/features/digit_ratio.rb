require 'wikipedia/vandalism_detection/features/base'
require 'wikipedia/vandalism_detection/diff'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the digit to all letters ratio of the edit's new revision inserted text.
      class DigitRatio < Base

        def calculate(edit)
          super

          old_text = edit.old_revision.text
          new_text = edit.new_revision.text
          inserted_letters = Wikipedia::VandalismDetection::Diff.new(old_text, new_text).inserted_words.join("")

          all_letters_count = inserted_letters.size
          digit_count = inserted_letters.scan(/\D/).size

          (1.0 + digit_count) / (1.0 + all_letters_count)
        end
      end
    end
  end
end
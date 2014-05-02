require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the character diversisty of the edit's new revision inserted text.
      # I.e. how many unique characters are amongst all inserted?
      #
      # Random typing leads to less unique characters relative to full length =>
      class CharacterDiversity < Base

        def calculate(edit)
          super

          inserted_letters = edit.inserted_text.scan(/[^\s]/)
          all_letters_count = inserted_letters.size
          unique_count = inserted_letters.uniq.size

          all_letters_count ** (1.0 / unique_count)
        end
      end
    end
  end
end
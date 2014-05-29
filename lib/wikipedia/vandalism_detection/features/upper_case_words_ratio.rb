require 'wikipedia/vandalism_detection/features/base'
require 'wikipedia/vandalism_detection/text'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the uppercase to all words ratio of the edit's new revision inserted text.
      class UpperCaseWordsRatio < Base

        def calculate(edit)
          super

          words = Text.new(edit.inserted_words.join("\n")).clean.gsub(/[^\w\s]/, '').split
          return 0.0 if words.empty?

          uppercase_words_count = words.reduce(0) do |count, word|
            count += 1 if word == word.upcase
            count
          end

          (1.0 + uppercase_words_count) / (1.0 + words.count)
        end
      end
    end
  end
end
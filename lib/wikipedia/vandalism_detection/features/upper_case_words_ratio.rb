# encoding: UTF-8

require 'wikipedia/vandalism_detection/features/base'
require 'wikipedia/vandalism_detection/text'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the uppercase to all words ratio of the edit's new revision inserted text.
      class UpperCaseWordsRatio < Base

        def calculate(edit)
          super

          inserted_alpha_text = edit.inserted_words.delete_if{ |w| w.gsub(/[^A-Za-z]/, '').empty? }.join("\n")
          words = Text.new(inserted_alpha_text).clean.gsub(/[^\w\s]/, '').split

          return 0.0 if words.empty?

          uppercase_words_count = words.reduce(0) do |count, word|
            count += 1 if word == word.upcase
            count
          end

          uppercase_words_count.zero? ? 0.0 : (uppercase_words_count.to_f / words.count.to_f)
        end
      end
    end
  end
end
require 'wikipedia/vandalism_detection/features/base'
require 'wikipedia/vandalism_detection/text'
require 'wikipedia/vandalism_detection/diff'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes average frequency of words inserted in the new
      # revision relative to the words in the old revision.
      class TermFrequency < FrequencyBase
        def calculate(edit)
          super

          new_text = edit.new_revision.text
          inserted_terms = Text.new(edit.inserted_words.join("\n"))
            .clean.gsub(/[^\w\s]/, '').split.uniq

          summed_frequencies = inserted_terms.reduce(0) do |count, term|
            count + frequency(new_text.clean, term)
          end

          if inserted_terms.count > 0
            summed_frequencies / inserted_terms.count
          else
            0.0
          end
        end
      end
    end
  end
end

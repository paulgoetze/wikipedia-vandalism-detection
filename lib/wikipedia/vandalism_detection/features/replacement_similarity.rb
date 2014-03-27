require 'wikipedia/vandalism_detection/features/base'
require 'fuzzystringmatch'
require 'wikipedia/vandalism_detection/diff'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the similarity of deleted to inserted text.
      # As similarity measure the Jaro-Winkler distance is used.
      # See: http://courses.cs.washington.edu/courses/cse590q/04au/papers/Winkler99.pdf
      class ReplacementSimilarity < Base

        def calculate(edit)
          super

          old_text = edit.old_revision.text
          new_text = edit.new_revision.text
          diff = Wikipedia::VandalismDetection::Diff.new(old_text, new_text)

          deleted_text = diff.removed_words.join(' ')
          inserted_text = diff.inserted_words.join(' ')

          jaro_winkler = FuzzyStringMatch::JaroWinkler.create(:pure)
          jaro_winkler.getDistance(deleted_text, inserted_text)
        end
      end
    end
  end
end
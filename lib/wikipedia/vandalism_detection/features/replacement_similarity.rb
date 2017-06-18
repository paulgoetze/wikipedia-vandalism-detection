require 'wikipedia/vandalism_detection/features/base'
require 'wikipedia/vandalism_detection/diff'
require 'hotwater'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes the similarity of deleted to inserted text.
      # As similarity measure the Jaro-Winkler distance is used.
      # See: http://courses.cs.washington.edu/courses/cse590q/04au/papers/Winkler99.pdf
      class ReplacementSimilarity < Base
        def calculate(edit)
          super

          ::Hotwater.jaro_winkler_distance(edit.removed_text, edit.inserted_text)
        end
      end
    end
  end
end

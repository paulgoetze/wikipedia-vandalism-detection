require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features
      class ContainsBase < Base
        # Returns whether the comment contains the given term.
        # It returns 0 if term is not included, else 1.
        def contains(comment, terms)
          terms = terms.is_a?(Array) ? terms.join('|') : terms
          comment.match(/#{terms}/i) ? 1 : 0
        end
      end
    end
  end
end

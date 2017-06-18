require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features
      class ImpactBase < Base
        # Returns the ratio of given text's terms count.
        # For impact calculation it returns 0.5 if number of terms in old text
        # is zero.
        def impact(old_text, new_text, terms)
          old_terms_count = (count terms, in: old_text).to_f
          new_terms_count = (count terms, in: new_text).to_f

          no_terms_in_both = old_terms_count.zero? && new_terms_count.zero?

          if no_terms_in_both
            0.5
          else
            old_terms_count / (old_terms_count + new_terms_count)
          end
        end
      end
    end
  end
end

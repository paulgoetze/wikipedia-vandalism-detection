require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features
      class FrequencyBase < Base
        # Returns the ratio of given numbers.
        # For frequency calculation it returns 0.0 if total_count is zero.
        def frequency(text, terms)
          total_count = text.split.count
          term_count = count terms, in: text

          total_count.positive? ? term_count.to_f / total_count.to_f : 0.0
        end
      end
    end
  end
end

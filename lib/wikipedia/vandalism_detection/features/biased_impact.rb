require 'wikipedia/vandalism_detection/features/impact_base'
require 'wikipedia/vandalism_detection/word_lists/biased'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes the percentage by which the edit increases the
      #  number of biased words in the text.
      class BiasedImpact < ImpactBase
        def calculate(edit)
          super

          old_text = edit.old_revision.text.clean
          new_text = edit.new_revision.text.clean

          impact(old_text, new_text, WordLists::BIASED)
        end
      end
    end
  end
end

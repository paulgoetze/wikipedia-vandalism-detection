require 'wikipedia/vandalism_detection/features/impact_base'
require 'wikipedia/vandalism_detection/word_lists/vulgarism'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes the percentage by which the edit increases the
      # number of vulgarism words in the text.
      class VulgarismImpact < ImpactBase
        def calculate(edit)
          super

          old_text = edit.old_revision.text.clean
          new_text = edit.new_revision.text.clean

          impact(old_text, new_text, WordLists::VULGARISM)
        end
      end
    end
  end
end

require 'wikipedia/vandalism_detection/features/base'
require 'wikipedia/vandalism_detection/algorithms'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes the Kullback-Leibler Divergence of the removed
      # text's character distribution relative to the character distribution
      # of the new revision's text.
      # The smaller the divergence, the higher the similarity of the
      # distributions and conversely.
      class RemovedCharacterDistribution < Base
        include Algorithms

        def calculate(edit)
          super

          kullback_leibler_divergence(edit.new_revision.text, edit.removed_text)
        end
      end
    end
  end
end

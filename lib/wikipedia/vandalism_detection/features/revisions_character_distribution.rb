require 'wikipedia/vandalism_detection/features/base'
require 'wikipedia/vandalism_detection/algorithms'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the Kullback-Leibler Divergence of the old and new text's character distribution.
      # The smaller the divergence, the higher the similarity of the distributions and conversely.
      class RevisionsCharacterDistribution < Base
        include Algorithms

        def calculate(edit)
          super

          kullback_leibler_divergence(edit.old_revision.text, edit.new_revision.text)
        end
      end
    end
  end
end
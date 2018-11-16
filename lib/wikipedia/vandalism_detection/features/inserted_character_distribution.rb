require 'wikipedia/vandalism_detection/features/base'
require 'wikipedia/vandalism_detection/algorithms'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes the Kullback-Leibler Divergence of the inserted
      # text's character distribution
      # relative to the character distribution of the old revision's text.
      # The smaller the divergence, the higher the similarity of the
      # distributions and conversely.
      class InsertedCharacterDistribution < Base
        include Algorithms

        def calculate(edit)
          super

          kullback_leibler_divergence(edit.old_revision.text, edit.inserted_text)
        end
      end
    end
  end
end

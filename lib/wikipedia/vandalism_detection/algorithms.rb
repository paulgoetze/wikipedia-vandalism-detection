require 'wikipedia/vandalism_detection/algorithms/kullback_leibler_divergence'

module Wikipedia
  module VandalismDetection
    module Algorithms
      def kullback_leibler_divergence(text_a, text_b)
        divergence = KullbackLeiblerDivergence.new
        divergence.of(text_a, text_b)
      end
    end
  end
end

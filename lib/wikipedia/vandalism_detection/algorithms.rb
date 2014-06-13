require 'active_support/concern'
require 'wikipedia/vandalism_detection/algorithms/kullback_leibler_divergence'

module Wikipedia
  module VandalismDetection
    module Algorithms
      extend ActiveSupport::Concern

      included do
        def kullback_leibler_divergence(text_a, text_b)
          divergence = KullBackLeiblerDivergence.new
          divergence.of text_a, text_b
        end
      end

    end
  end
end
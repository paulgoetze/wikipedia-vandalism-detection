require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Algorithms
      class KullbackLeiblerDivergence
        ALLOWED_ERROR = 9e-6

        # Returns the Symmetric Kullback-Leibler divergence with simple back-off
        # of the given text's character distribution. For implementation details
        # see: https://web.archive.org/web/20130508191111/http://staff.science.uva.nl/~tsagias/?p=185.
        def of(text_a, text_b)
          text_a = cleanup_text(text_a)
          text_b = cleanup_text(text_b)

          unless text_a.match(/[[:alnum:]]/) && text_b.match(/[[:alnum:]]/)
            return Features::MISSING_VALUE
          end

          distribution_a = character_distribution(text_a)
          distribution_b = character_distribution(text_b)

          sum_a = distribution_a.values.inject(0, :+)
          sum_b = distribution_b.values.inject(0, :+)

          character_diff = distribution_b.keys - distribution_a.keys

          epsilon = [
            distribution_a.values.min / sum_a,
            distribution_b.values.min / sum_b
          ].min * 0.001

          gamma = 1 - character_diff.size * epsilon

          check_integrity(distribution_a, sum_a)
          check_integrity(distribution_b, sum_b)

          divergence = 0.0

          distribution_a.each do |character, distribution|
            prob_a = distribution / sum_a

            character_distribution = distribution_b[character]

            prob_b =
              if character_distribution
                gamma * (character_distribution / sum_b)
              else
                epsilon
              end

            divergence += (prob_a - prob_b) * Math.log(prob_a / prob_b)
          end

          divergence
        end

        private

        # Removes invalid utf-8 characters
        def cleanup_text(text)
          text.encode(
            'UTF-8',
            'binary',
            invalid: :replace,
            undef: :replace,
            replace: ''
          )
        end

        # Returns a hash representing each character's distribution
        def character_distribution(text)
          distribution = {}
          return distribution if text.empty?

          characters = text.downcase.scan(/[[:alnum:]]/)

          characters.each do |character|
            if distribution.key?(character.to_sym)
              distribution[character.to_sym] += 1
            else
              distribution[character.to_sym] = 1
            end
          end

          Hash[distribution.map do |key, value|
            [key, value / characters.count.to_f]
          end]
        end

        # Checks if values sum up to 1.0, raises an error if they don't.
        def check_integrity(distribution, sum)
          difference = 1.0 - distribution.values
            .inject(0) { |result, value| result + (value / sum) }.abs

          return if difference <= ALLOWED_ERROR

          raise(Exception, 'Text distribution does not sum up to 1.0')
        end
      end
    end
  end
end

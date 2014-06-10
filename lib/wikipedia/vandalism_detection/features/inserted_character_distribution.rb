require 'wikipedia/vandalism_detection/features/base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the Kullback-Leibler Divergence of the inserted text's character distribution
      # relative to the character distribution of the old revision's text.
      # The smaller the divergence, the higher the similarity of the distributions and conversely.
      class InsertedCharacterDistribution < Base

        def calculate(edit)
          super

          kullback_leibler_divergence(edit.old_revision.text.clean, edit.inserted_text)
        end

        private

        # Returns the Symmetric Kullback-Leibler divergence with simple back-off of the given text's character
        # distribution. For implementation details, see: http://staff.science.uva.nl/~tsagias/?p=185
        def kullback_leibler_divergence(text_a, text_b)
          return Float::MAX if text_a.size == 0 || text_b.size == 0

          distribution_a = character_distribution(text_a)
          distribution_b = character_distribution(text_b)

          sum_a = distribution_a.values.inject(:+)
          sum_b = distribution_b.values.inject(:+)

          character_diff = (distribution_b.keys - distribution_a.keys)

          epsilon = [(distribution_a.values.min / sum_a), (distribution_b.values.min / sum_b)].min * 0.001
          gamma = 1 - character_diff.size * epsilon

          # check if values sum up to 1.0
          sum_a_diff = 1.0 - distribution_a.values.inject(0) { |sum, value| sum += value / sum_a }.abs
          sum_b_diff = 1.0 - distribution_b.values.inject(0) { |sum, value| sum += value / sum_b }.abs

          raise(Exception, "Text a distr. does not sum up to 1.0") if sum_a_diff > 9e-6
          raise(Exception, "Text b distr. does not sum up to 1.0") if sum_b_diff > 9e-6

          divergence = 0.0

          distribution_a.each do |character, distribution|
            prob_a = distribution / sum_a
            prob_b = (distribution_b.has_key?(character) ? (gamma * (distribution_b[character] / sum_b)) : epsilon)

            divergence += ((prob_a - prob_b) * Math.log(prob_a / prob_b))
          end

          divergence
        end

        # Returns a hash representing each character's distribution
        def character_distribution(text)
          distribution = {}
          return distribution if text.empty?

          characters = text.downcase.scan(/[[:alpha:]]/)

          characters.each do |character|
            if distribution.has_key?(character.to_sym)
              distribution[character.to_sym] += 1
            else
              distribution[character.to_sym] = 1
            end
          end

          Hash[distribution.map { |key, value| [key, value / characters.count.to_f] }]
        end

      end
    end
  end
end
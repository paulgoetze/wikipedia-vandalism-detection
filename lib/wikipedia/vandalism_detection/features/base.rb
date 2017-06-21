require 'wikipedia'

module Wikipedia
  module VandalismDetection
    module Features
      MISSING_VALUE = '?'.freeze

      # This class should be the base class for all Wikipedia::Feature classes.
      class Base
        # Base method for feature calculation.
        # This method should be overwritten in the concrete
        # Wikipedia::Feature-classes.
        #
        # @example
        #   def calculate(edit)
        #     super # to handle ArgumentException
        #
        #     ... concrete calculation of feature out of edit...
        #   end
        def calculate(edit)
          return if edit.is_a?(Edit)
          raise ArgumentError, 'Passed argument has to be an Edit'
        end

        # Count the apperance of a given single term or multiple terms in the
        #   given text
        #
        # @param terms String
        # @param options Hash of form { in: String }
        #
        # @example
        #   feature.count "and", in: text
        #   feature.count ["and", "or"], in: text
        #
        # @return Integer
        def count(terms, options = {})
          unless options[:in]
            raise ArgumentError, 'The options hash must include the in: key'
          end

          unless terms.is_a?(String) || terms.is_a?(Array)
            raise ArgumentError, 'The 1st arg should be an Array or String'
          end

          words = options[:in].downcase
          freq = Hash.new(0)

          words.gsub(/[\.,'{2,}:\!\?\(\)]/, '').split.each do |word|
            freq[word.to_sym] += 1
          end

          if terms.is_a?(String)
            freq[terms.downcase.to_sym]
          else
            terms.reduce(0) { |result, term| result + freq[term] }
          end
        end
      end
    end
  end
end

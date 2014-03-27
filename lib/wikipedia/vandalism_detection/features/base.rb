module Wikipedia
  module VandalismDetection
    module Features

      # This class should be the base class for all Wikipedia::Feature classes.
      class Base

        # Base method for feature calculation.
        # This method should be overwritten in the concrete Wikipedia::Feature-classes.
        #
        # Example:
        # def calculate(edit)
        #   super # to handle ArgumentException
        #
        #   ... concrete calculation of feature out of edit...
        # end
        def calculate(edit)
          raise ArgumentError.new "parameter should be an Edit" unless edit.kind_of? Edit
        end

        # Count the apperance of a given single term or multiple terms in the given text
        # @params terms String
        # @params options Hash of form {in: String}
        #
        # Example of usage:
        #
        # feature.count "and", in: text
        # feature.count ["and", "or"], in: text
        def count(terms, options = {})
          terms_is_string = terms.is_a?(String)
          terms_is_array = terms.is_a?(Array)

          raise ArgumentError, "The second parameter should be a Hash of form {in: text}" unless options[:in]
          raise ArgumentError, "The first parameter should be an Array or String" unless
              (terms_is_array || terms_is_string)

          words = options[:in].downcase
          freq = Hash.new(0)
          words.gsub(/[\.,'{2,}:\!\?\(\)]/, '').split.each{ |v| freq[v.to_sym] += 1 }

          if terms_is_string
            freq[terms.downcase.to_sym]
          else
            terms.reduce(0) {|r, term| r + freq[term] }
          end

=begin
          # original version
          terms_join = terms.is_a?(String) ? terms : terms.join("|")

          regex = /\b(#{terms_join})\b/i
          puts regex
          text = options[:in]

          matches = text.scan(regex)
          matches ? matches.size : 0
=end
        end
      end
    end
  end
end
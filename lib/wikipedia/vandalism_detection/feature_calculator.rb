require 'active_support/core_ext/string'
require 'active_support/core_ext/array'

require 'wikipedia/vandalism_detection/wikitext_extractor'
require 'wikipedia/vandalism_detection/features'
require 'wikipedia/vandalism_detection/edit'

module Wikipedia
  module VandalismDetection

    # This class provides methods for calculating a feature set of an edit.
    # The features that shall be used can be defined in the conf/config.yml file
    # under the features: root attribute like this:
    #
    # features:
    #   - anonymity
    #   - character sequence
    #   - ...
    # etc.
    #
    # @author Paul Götze <paul.christoph.goetze@gmail.com>
    class FeatureCalculator

      def initialize
        @features = Wikipedia::VandalismDetection.configuration.features
        raise FeaturesNotConfiguredError if (@features.blank? || @features.empty?)
        @feature_classes = build_feature_classes @features
      end

      # Calculates the configured festures for the given edit and
      # returns an array of the computed values.
      def calculate_features_for(edit)
        raise ArgumentError, "Input has to be an Edit." unless edit.is_a? Edit

        contains_redirect = edit.old_revision.redirect? || edit.new_revision.redirect?

        features = contains_redirect ? [] : @feature_classes.map do |feature|
          begin
            feature.calculate(edit)
          rescue WikitextExtractionError => e
            $stderr.puts e.message
            $stderr.print %Q{
            Error while calculating features for edit with
              old revision: #{edit.old_revision.id}
              new revision: #{edit.new_revision.id}

            This edit could not be parsed by the WikitextExtractor and will be discarded.\n}

            -1
          end
        end

        features
      end

      # Returns the feature names as defined in conf/config.yml under 'features:'.
      def used_features
        @features
      end

      private

      # Returns an array of all configured Feature class instances.
      def build_feature_classes(feature_names)
        feature_names.map do |name|
          camelcased_name = name.split(/[\s-]/).map{ |s| s.capitalize! }.join('')
          "Wikipedia::VandalismDetection::Features::#{camelcased_name}".constantize.new
        end
      end
    end
  end
end
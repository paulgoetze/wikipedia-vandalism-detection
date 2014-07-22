require 'active_support/core_ext/string'
require 'active_support/core_ext/array'

require 'wikipedia/vandalism_detection/wikitext_extractor'
require 'wikipedia/vandalism_detection/features'
require 'wikipedia/vandalism_detection/edit'

module Wikipedia
  module VandalismDetection

    # This class provides methods for calculating a feature set of an edit.
    # The features that shall be used can be defined in the config/config.yml file
    # under the 'features:' root attribute like this:
    #
    # features:
    #   - anonymity
    #   - character sequence
    #   - ...
    # etc.
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

        features = @feature_classes.map do |feature|
          begin
            feature.calculate(edit)
          rescue WikitextExtractionError => e
            $stderr.print %Q{
              Edit (#{edit.old_revision.id}, #{edit.new_revision.id}) could not be parsed
              by the WikitextExtractor and will be discarded.\n""}

            Features::MISSING_VALUE
          end
        end

        features
      end

      # Returns the calculated Numeric feature value for given edit and feature with given name
      def calculate_feature_for(edit, feature_name)
        raise ArgumentError, "First parameter has to be an Edit." unless edit.is_a? Edit
        raise ArgumentError, "Second parameter has to be a feature name String (e.g. 'anonymity')." unless \
          feature_name.is_a? String

        value = Features::MISSING_VALUE

        begin
          feature = feature_class_from_name(feature_name)
          value = feature.calculate(edit)
        rescue WikitextExtractionError
          $stderr.print %Q{
            Edit (#{edit.old_revision.id}, #{edit.new_revision.id}) could not be parsed
            by the WikitextExtractor and will be discarded.\n""}
        end

        value
      end

      # Returns the feature names as defined in conf/config.yml under 'features:'.
      def used_features
        @features
      end

      private

      # Returns an array of all configured Feature class instances.
      def build_feature_classes(feature_names)
        feature_names.map do |name|
          feature_class_from_name(name)
        end
      end

      # Returns the Feature class of the given name
      def feature_class_from_name(name)
        camelcased_name = name.split(/[\s-]/).map{ |s| s.capitalize! }.join('')
        "Wikipedia::VandalismDetection::Features::#{camelcased_name}".constantize.new
      end
    end
  end
end
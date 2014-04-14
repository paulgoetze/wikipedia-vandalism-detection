require 'ruby-band'
require 'active_support/core_ext/string'
require 'fileutils'

require 'wikipedia/vandalism_detection/configuration'
require 'wikipedia/vandalism_detection/edit'
require 'wikipedia/vandalism_detection/feature_calculator'
require 'wikipedia/vandalism_detection/instances'
require 'wikipedia/vandalism_detection/evaluator'

module Wikipedia
  module VandalismDetection
    class Classifier

      attr_reader :evaluator, :dataset

      # Loads the classifier instance configured in the config file.
      def initialize
        @config = Wikipedia::VandalismDetection.configuration
        @feature_calculator = FeatureCalculator.new
        @classifier = load_classifier
        @evaluator = Evaluator.new(self)
      end

      # Returns the concrete classifier instance configured in the config file
      # When you configured a Trees::RandomForest classifier you will get a Weka::Classifiers::Trees::RandomForest
      # instance.
      # This instance can be used for native function callings of the classifier class.
      def classifier_instance
        @classifier
      end

      # Classifies an edit or a set of features and returns the vandalism consensus by default
      # If 'return_all_params = true' is set, it returns a Hash of form
      # { consensus => ..., class_index => ...}
      #
      # @example
      #   # suppose you have a dataset with 2 feature or 'edit' as an instance of Wikipedia::VandalismDetection::Edit
      #   classifier = Wikipedia::VandalsimDetection::Classifier.new
      #   features = [0.45, 0.67]
      #
      #   consensus = classifier.classify(features)
      #   consensus = classifier.classify(edit)
      def classify(edit_or_features, options = {})
        features = @config.features
        param_is_features = edit_or_features.is_a?(Array) && (edit_or_features.size == features.count)
        param_is_edit = edit_or_features.is_a? Edit

        unless param_is_edit || param_is_features
          raise ArgumentError, "Input has to be an Edit or an Array of feature values."
        end

        feature_values = param_is_edit ? @feature_calculator.calculate_features_for(edit_or_features) : edit_or_features
        return -1.0 if feature_values.empty?

        dataset = Instances.empty
        dataset.set_class_index feature_values.count
        dataset.add_instance(feature_values)

        results = []

        dataset.each_row do |instance|
          if options[:return_all_params]
            confidence = (@classifier.distribution_for_instance(instance).to_a).first
            class_index = @classifier.classify_instance(instance).to_i

            results = { confidence: confidence, class_index: class_index }
          else
            results = (@classifier.distribution_for_instance(instance).to_a).first
          end
        end

        results
      end

      # Cross validates the classifier.
      # Fold is used as defined in configuration (default is 10).
      #
      # @example
      #   classifier = Wikipedia::VandalismDetection::Classifier.new
      #   evaluation = classifier.cross_validate
      #   evaluation = classifier.cross_validate(equally_distributed: true)
      #
      def cross_validate(options = {})
        @evaluator.cross_validate(options)
      end

      private

      # Loads the (Weka-) Classifier set in the Configuration
      def load_classifier
        classifier_name = @config.classifier_type

        raise ClassifierNotConfiguredError, "You have to define a classifier type in config.yml" unless classifier_name

        begin
          "Weka::Classifiers::#{classifier_name}::Base".constantize
        rescue
          raise ClassifierUnknownError, "The configured classifier type '#{classifier_name}' is unknown."
        end

        raise FeaturesNotConfiguredError, "You have to configure features in config.yml" if @config.features.blank?

        classifier_class = "Weka::Classifiers::#{classifier_name}::Base".constantize
        @dataset = TrainingDataset.instances
        dataset = @dataset
        options = @config.classifier_options

        begin
          classifier = classifier_class.new do
            set_data dataset
            set_class_index dataset.class_index
            set_options options if options
          end

          classifier
        rescue => e
          raise "Error while loading classfier: #{e}"
        end
      end
    end
  end
end
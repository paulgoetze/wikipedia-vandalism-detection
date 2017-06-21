require 'weka'
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
      def initialize(dataset = nil)
        @config = Wikipedia::VandalismDetection.config
        @feature_calculator = FeatureCalculator.new
        @classifier = load_classifier(dataset)
        @evaluator = Evaluator.new(self)
      end

      # Returns the concrete classifier instance configured in the config file
      # When you configured a Trees::RandomForest classifier you will get a
      # Weka::Classifiers::Trees::RandomForest instance.
      # This instance can be used for native function callings of the classifier
      # class.
      def classifier_instance
        @classifier
      end

      # Classifies an edit or a set of features and returns the vandalism
      # confidence by default.
      # If option 'return_all_params: true' is set, it returns a Hash of form
      # { confidence => ..., class_index => ...}
      #
      # @example
      #   # suppose you have a dataset with 2 feature or 'edit' as an instance
      #   # of Wikipedia::VandalismDetection::Edit
      #   classifier = Wikipedia::VandalsimDetection::Classifier.new
      #   features = [0.45, 0.67]
      #
      #   confidence = classifier.classify(features)
      #   confidence = classifier.classify(edit)
      def classify(edit_or_features, options = {})
        features = @config.features
        param_is_features = edit_or_features.is_a?(Array) && edit_or_features.size == features.count
        param_is_edit = edit_or_features.is_a? Edit

        unless param_is_edit || param_is_features
          message = 'Input has to be an Edit or an Array of feature values.'
          raise ArgumentError, message
        end

        feature_values = param_is_edit ? @feature_calculator.calculate_features_for(edit_or_features) : edit_or_features
        return -1.0 if feature_values.empty?

        feature_values = feature_values.map do |i|
          i == Features::MISSING_VALUE ? nil : i
        end

        dataset = Instances.empty
        dataset.set_class_index(feature_values.count)
        dataset.add_instance([*feature_values, Instances::VANDALISM])

        instance = dataset.instance(0)
        instance.set_class_missing

        if @config.use_occ?
          if @config.classifier_options =~ /#{Instances::VANDALISM}/
            index = Instances::VANDALISM_CLASS_INDEX
          else
            index = Instances::REGULAR_CLASS_INDEX
          end
        else
          index = Instances::VANDALISM_CLASS_INDEX
        end


        confidence = @classifier.distribution_for_instance(instance).to_a[index]

        if options[:return_all_params]
          class_index = @classifier.classify_instance(instance)
          class_index = class_index.nan? ? Instances::NOT_KNOWN_INDEX : class_index.to_i
          results = { confidence: confidence, class_index: class_index }
        else
          results = confidence
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
      def load_classifier(dataset)
        classifier_name = @config.classifier_type

        unless classifier_name
          message = 'Classifier type is not defined in wikipedia-vandalism-detection.yml'
          raise ClassifierNotConfiguredError, message
        end

        if @config.features.blank?
          message = 'No features configured in wikipedia-vandalism-detection.yml'
          raise FeaturesNotConfiguredError, message
        end

        begin
          "Weka::Classifiers::#{classifier_name}".constantize
        rescue
          message = "The configured classifier type '#{classifier_name}' is unknown."
          raise ClassifierUnknownError, message
        end

        classifier_class = "Weka::Classifiers::#{classifier_name}".constantize
        options = @config.classifier_options

        puts "Loading classifier #{classifier_name} with options '#{options}'…"

        if dataset.nil?
          if @config.balanced_training_data?
            puts 'using BALANCED training dataset'
            dataset = TrainingDataset.balanced_instances
          elsif @config.unbalanced_training_data?
            puts 'using FULL (unbalanced) training dataset'
            dataset = TrainingDataset.instances
          elsif @config.oversampled_training_data?
            puts 'using OVERSAMPLED training dataset'
            dataset = TrainingDataset.oversampled_instances
          end
        end

        if @config.use_occ?
          dataset.rename_attribute_value(
            dataset.class_index,
            one_class_index,
            Instances::OUTLIER
          )
        end

        @dataset = dataset

        begin
          classifier = classifier_class.build do
            use_options options if options
            train_with_instances dataset
          end

          classifier
        rescue => error
          raise "Error while loading classifier: #{error}"
        end
      end

      def one_class_index
        if @config.classifier_options =~ /#{Instances::VANDALISM}/
          Instances::REGULAR_CLASS_INDEX
        else
          Instances::VANDALISM_CLASS_INDEX
        end
      end

      # Returns the given dataset cleaned up the regular instances
      def remove_regular_instances(dataset)
        features = @config.features

        vandalism_dataset = Weka::Core::Instances.new.with_attributes do
          features.each { |name| numeric :"#{name.tr(' ', '_')}" }
          nominal :class, values: [Instances::VANDALISM], class_attribute: true
        end

        dataset.to_a.map(&:values).each_with_index do |attributes, index|
          class_value = Instances::CLASSES[dataset.instance(index).value(dataset.class_index).to_i]

          if class_value == Instances::VANDALISM
            values = attributes[0..-2]
            vandalism_dataset.add_instance([*values, class_value])
          end
        end

        filter = Weka::Filters::Unsupervised::Attribute::Normalize.new
        vandalism_dataset = filter.filter(vandalism_dataset)

        vandalism_dataset
      end
    end
  end
end

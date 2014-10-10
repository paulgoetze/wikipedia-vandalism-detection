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
      def initialize(dataset = nil)
        @config = Wikipedia::VandalismDetection.configuration
        @feature_calculator = FeatureCalculator.new
        @classifier = load_classifier(dataset)
        @evaluator = Evaluator.new(self)
      end

      # Returns the concrete classifier instance configured in the config file
      # When you configured a Trees::RandomForest classifier you will get a Weka::Classifiers::Trees::RandomForest
      # instance.
      # This instance can be used for native function callings of the classifier class.
      def classifier_instance
        @classifier
      end

      # Classifies an edit or a set of features and returns the vandalism confidence by default
      # If option 'return_all_params: true' is set, it returns a Hash of form
      # { confidence => ..., class_index => ...}
      #
      # @example
      #   # suppose you have a dataset with 2 feature or 'edit' as an instance of Wikipedia::VandalismDetection::Edit
      #   classifier = Wikipedia::VandalsimDetection::Classifier.new
      #   features = [0.45, 0.67]
      #
      #   confidence = classifier.classify(features)
      #   confidence = classifier.classify(edit)
      def classify(edit_or_features, options = {})
        features = @config.features
        param_is_features = edit_or_features.is_a?(Array) && (edit_or_features.size == features.count)
        param_is_edit = edit_or_features.is_a? Edit

        unless param_is_edit || param_is_features
          raise ArgumentError, "Input has to be an Edit or an Array of feature values."
        end

        feature_values = param_is_edit ? @feature_calculator.calculate_features_for(edit_or_features) : edit_or_features
        return -1.0 if feature_values.empty?

        feature_values = feature_values.map { |i| i == Features::MISSING_VALUE ? nil : i }

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


        confidence = (@classifier.distribution_for_instance(instance).to_a)[index]

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

        raise ClassifierNotConfiguredError, "You have to define a classifier type in wikipedia-vandalism-detection.yml" unless classifier_name
        raise FeaturesNotConfiguredError, "You have to configure features in wikipedia-vandalism-detection.yml" if @config.features.blank?

        begin
          "Weka::Classifiers::#{classifier_name}::Base".constantize
        rescue
          raise ClassifierUnknownError, "The configured classifier type '#{classifier_name}' is unknown."
        end

        classifier_class = "Weka::Classifiers::#{classifier_name}::Base".constantize
        options = @config.classifier_options

        puts "Loading classifier #{classifier_name} with options '#{options}'..."

        if dataset.nil?
          if @config.balanced_training_data?
            puts "using BALANCED training dataset"
            dataset = TrainingDataset.balanced_instances
          elsif @config.unbalanced_training_data?
            puts "using FULL (unbalanced) training dataset"
            dataset = TrainingDataset.instances
          elsif @config.oversampled_training_data?
            puts "using OVERSAMPLED training dataset"
            dataset = TrainingDataset.oversampled_instances
          end
        end

        if @config.use_occ?
          dataset.rename_attribute_value(dataset.class_index, one_class_index, Instances::OUTLIER)
        elsif @config.classifier_type.match('Functions::LibSVM')
          dataset = remove_regular_instances(dataset)
        end

        @dataset = dataset

        begin
          classifier = classifier_class.new do
            set_data dataset
            set_class_index dataset.class_index
            set_options options if options
          end

          classifier
        rescue => e
          raise "Error while loading classifier: #{e.class}: #{e.message}"
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

        vandalism_dataset = Core::Type::Instances::Base.new do
          features.each { |name| numeric :"#{name.gsub(' ', '_')}" }
          nominal :class, [Instances::VANDALISM]
        end

        dataset.to_a2d.each_with_index do |attributes, index|
          class_value = Instances::CLASSES[dataset.instance(index).value(dataset.class_index).to_i]
          vandalism_dataset.add_instance([*attributes, class_value]) if  class_value == Instances::VANDALISM
        end

        filter = Weka::Filters::Unsupervised::Attribute::Normalize.new
        filter.data(vandalism_dataset)
        vandalism_dataset = filter.use
        vandalism_dataset.class_index = features.count

        vandalism_dataset
      end
    end
  end
end
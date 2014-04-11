require 'wikipedia/vandalism_detection/configuration'
require 'wikipedia/vandalism_detection/training_dataset'
require 'wikipedia/vandalism_detection/classifier'
require 'wikipedia/vandalism_detection/instances'
require 'ruby-band'
require 'fileutils'

module Wikipedia
  module VandalismDetection

    # This class provides methods for the evaluation of a Wikipedia::VandalismDetection::Classifier
    # using the weka framwork.
    #
    # @example
    #   classifier = Wikipedia::VandalismDetection::Classifier.new
    #   evaluator = Wikipedia::VandalsimDetection::Evaluator(classifier)
    #
    #   evaluation = evaluator.cross_validate
    #   evaluation = evaluator.cross_validate(equally_distributed: true)
    #
    #   puts evaluation[:precision]
    #   puts evaluation[:recall]
    #   puts evaluation[:area_under_prc]
    class Evaluator

      def initialize(classifier)
        raise(ArgumentError, "Classifier param has to be a Wikipedia::VandalismDetection::Classifier instance") unless
            classifier.is_a?(Wikipedia::VandalismDetection::Classifier)

        @config = Wikipedia::VandalismDetection.configuration
        @classifier = classifier.classifier_instance
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
        equally_distributed = options[:equally_distributed]

        fold_defaults = Wikipedia::VandalismDetection::DefaultConfiguration::DEFAULTS['classifier']['cross-validation-fold']
        fold = (@config.cross_validation_fold || fold_defaults)

        if equally_distributed
          cross_validate_equally_distributed(fold)
        else
          cross_validate_all_instances(fold)
        end
      end

      # Returns a Hash comprising the evaluation curve data Arrays for precision, recall
      #
      # @example
      #   classifier = Wikipedia::VandalismDetection::Classifier.new
      #   evaluator = classifier.evaluator
      # or
      #   classifier = Wikipedia::VandalismDetection::Classifier.new
      #   evaluator = Wikipedia::VandalismDetection::Evaluator.new(classifier)
      #
      #   curve_data = evaluator.curve_data
      #
      #   curve_data[:precision]
      #   # => [0.76, ..., 0.91]
      #
      #   curve_data[:recall]
      #   # => [0.87, ..., 0.89]
      #
      #   curve_data[:area_under_prc]
      #   # => 0.83
      def curve_data(options = {})
        evaluations = cross_validate(options)
        threshold_curve = Weka::Classifiers::Evaluation::ThresholdCurve.new

        evaluation_data = (evaluations.is_a? Array) ? evaluations[0] : evaluations

        instances = threshold_curve.curve(evaluation_data.predictions, Instances::VANDALISM_CLASS_INDEX)
        precision = instances.return_attr_data('Precision')
        recall = instances.return_attr_data('Recall')
        area_under_prc = evaluation_data.area_under_prc(Instances::VANDALISM_CLASS_INDEX)

        {precision: precision, recall: recall, area_under_prc: area_under_prc }
      end

      private

      # Cross validates classifier over full dataset with <fold>-fold cross validation
      def cross_validate_all_instances(fold)
        begin
          @classifier.cross_validate(fold)
        rescue => e
          raise "Error while cross validation: #{e}"
        end
      end

      # Cross validates classifier over equally distributed dataset with <fold>-fold cross validation
      def cross_validate_equally_distributed(fold)
        dirname = @config.output_base_directory
        FileUtils.mkdir(dirname) unless Dir.exists?(dirname)

        file_name = 'cross_validation_eq_distr.txt'
        file_path = File.join(dirname, file_name)

        puts "Writing to #{file_path}..."
        result_file = File.open(file_path, 'a')

        begin
          dataset_arff = TrainingDataset.instances
          dataset_vandalism = Instances.empty
          dataset_regular = Instances.empty

          dataset_arff.each_row do |instance|
            label = Instances::CLASSES[instance.class_value.to_i]

            if label == Instances::VANDALISM
              dataset_vandalism.add(instance)
            else
              dataset_regular.add(instance)
            end
          end

          vandalism_count = dataset_vandalism.n_rows
          regular_count = dataset_regular.n_rows
          min_count = [vandalism_count, regular_count].min

          smaller_dataset = (vandalism_count >= regular_count) ? dataset_regular : dataset_vandalism
          bigger_dataset = (vandalism_count >= regular_count) ? dataset_vandalism : dataset_regular

          time = Time.now.strftime("%Y-%m-%d %H:%M")
          type = @config.classifier_type
          options = @config.classifier_options || "default"
          result_file.puts "\nCROSS VALIDATION - #{fold} fold (Classifier: #{type}, options: #{options} ) | #{time}"
          result_file.puts "Features: \n\t#{@config.features.join("\n\t")}\n\n"

          evaluations = []

          times = 10

          # run n times validation
          (1..times).each do |i|
            temp_dataset = smaller_dataset
            temp_dataset_bigger = bigger_dataset

            while temp_dataset.n_rows < (2 * min_count)
              random_index = SecureRandom.random_number(temp_dataset_bigger.n_rows)
              instance = temp_dataset_bigger.instance(random_index)

              temp_dataset.add(instance)
              temp_dataset_bigger.delete(random_index)
            end

            print "\rcross validate dataset  (equally distributed) ... #{i}/#{times} | instances: #{temp_dataset.n_rows}"
            @classifier.set_data(temp_dataset)
            evaluations << @classifier.cross_validate(fold)

            print_evaluation_data(evaluations, result_file, i) if (i % (times / 10)) == 0
          end

          #evaluation_data_of(evaluations)
          evaluations
        rescue => e
          raise "Error while cross validation for equally distributed instances: #{e}"
        ensure
          result_file.close
          puts "\nThe evaulation results has been saved to #{file_path}"
        end
      end

      # Returns the evaluation data average value hash of the given evaluations.
      def evaluation_data_of(evaluations)
        class_index = Instances::VANDALISM_CLASS_INDEX
        total_count = evaluations.count.to_f

        recall = evaluations.reduce(0.0) { |result, sample| result + sample.recall(class_index) } / total_count
        precision = evaluations.reduce(0.0) { |result, sample| result + sample.precision(class_index) } / total_count
        area_under_prc = evaluations.reduce(0.0) { |result, sample| result + sample.area_under_prc(class_index) } / total_count

        { precision: precision, recall: recall, area_under_prc: area_under_prc }
      end

      # Prints data to file
      def print_evaluation_data(evaluations, file, index)
        data = evaluation_data_of(evaluations)
        file.puts "#{index}\tprecision: #{data[:precision]} | recall: #{data[:recall]} | Area under PRC: #{data[:area_under_prc]}"
      end
    end
  end
end
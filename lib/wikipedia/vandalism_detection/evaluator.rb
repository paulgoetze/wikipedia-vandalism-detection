require 'wikipedia/vandalism_detection/configuration'
require 'wikipedia/vandalism_detection/exceptions'
require 'wikipedia/vandalism_detection/training_dataset'
require 'wikipedia/vandalism_detection/test_dataset'
require 'wikipedia/vandalism_detection/classifier'
require 'wikipedia/vandalism_detection/instances'
require 'weka'
require 'fileutils'
require 'csv'

module Wikipedia
  module VandalismDetection
    # This class provides methods for the evaluation of a
    # Wikipedia::VandalismDetection::Classifier using the weka framwork.
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
      DEFAULT_SAMPLE_COUNT = 200
      DEFAULTS = Wikipedia::VandalismDetection::DefaultConfiguration::DEFAULTS

      def initialize(classifier)
        unless classifier.is_a?(Wikipedia::VandalismDetection::Classifier)
          message = 'The classifier argument has to be an instance of ' \
                    'Wikipedia::VandalismDetection::Classifier'
          raise ArgumentError, message
        end

        @config = Wikipedia::VandalismDetection.config
        @classifier = classifier
        @classifier_instance = classifier.classifier_instance
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

        fold_defaults = DEFAULTS['classifier']['cross-validation-fold']
        fold = @config.cross_validation_fold || fold_defaults

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

        evaluation_data = evaluations.is_a?(Array) ? evaluations[0] : evaluations

        instances = threshold_curve.curve(
          evaluation_data.predictions,
          Instances::VANDALISM_CLASS_INDEX
        )

        precision = instances.attribute_to_double_array(0).to_a
        recall = instances.attribute_to_double_array(1).to_a
        area_under_prc = evaluation_data.area_under_prc(Instances::VANDALISM_CLASS_INDEX)

        {
          precision: precision,
          recall: recall,
          area_under_prc: area_under_prc
        }
      end

      # Evaluates the classification of the configured test corpus against the
      # given ground truth.
      # Runs the file creation automatically unless the classification file
      # exists, yet.
      #
      # Number of samples to use can be set by 'sample_count: <number>'
      # option. Default number of samples is 100.
      #
      # Returns a Hash with values:
      #   :recalls - recall values
      #   :precisions - precision values
      #   :fp_rates - fals positive rate values
      #   :auprc - area under precision recall curve
      #   :auroc - area under receiver operator curve
      #   :total_recall - overall classifier recall value
      #   :total_precision - overall classifier precision value
      #
      # @example
      #   classifier = Wikipedia::VandalismDetection::Classifier.new
      #   evaluator = classifier.evaluator
      # or
      #   classifier = Wikipedia::VandalismDetection::Classifier.new
      #   evaluator = Wikipedia::VandalismDetection::Evaluator.new(classifier)
      #
      #   evaluator.evaluate_testcorpus_classification
      #   evaluator.evaluate_testcorpus_classification(sample_count: 50)
      #
      def evaluate_testcorpus_classification(options = {})
        ground_truth_file_path = @config.test_corpus_ground_truth_file

        unless ground_truth_file_path
          message = 'Ground truth file path has to be set for test set evaluation'
          raise GroundTruthFileNotConfiguredError, message
        end

        unless File.exist?(ground_truth_file_path)
          message = 'Configured ground truth file is not available.'
          raise GroundTruthFileNotFoundError, message
        end

        ground_truth = ground_truth_hash(ground_truth_file_path)
        create_testcorpus_classification_file!(@config.test_output_classification_file, ground_truth)
        classification = classification_hash(@config.test_output_classification_file)

        sample_count = options[:sample_count] || DEFAULT_SAMPLE_COUNT
        curves = test_performance_curves(ground_truth, classification, sample_count)
        precision_recall = maximum_precision_recall(curves[:precisions], curves[:recalls])

        curves[:total_recall] = precision_recall[:recall]
        curves[:total_precision] = precision_recall[:precision]

        curves
      end

      # Returns the performance curve points (recall, precision, fp-rate) and
      # computed area under curves.
      def test_performance_curves(ground_truth, classification, sample_count)
        thresholds = (0.0...1.0).step(1.0 / sample_count.to_f).to_a

        # remove first value to not use the [0,1] value in curve
        thresholds.shift

        precisions = []
        recalls = []
        fp_rates = []

        thresholds.each do |threshold|
          values = predictive_values(ground_truth, classification, threshold)
          performance_params = performance_parameters(
            values[:tp],
            values[:fp],
            values[:tn],
            values[:fn]
          )

          precisions.push performance_params[:precision]
          recalls.push performance_params[:recall]
          fp_rates.push performance_params[:fp_rate]
        end

        tp_rates = recalls
        pr_sorted = sort_curve_values(recalls, precisions, x: 0.0, y: 0.0)
        roc_sorted = sort_curve_values(fp_rates, tp_rates, y: 0.0, x: 1.0)

        recalls = pr_sorted[:x]
        precisions = pr_sorted[:y]
        fp_rates = roc_sorted[:x]
        tp_rates = roc_sorted[:y]

        pr_auc = area_under_curve(recalls, precisions)
        roc_auc = area_under_curve(fp_rates, tp_rates)

        {
          precisions: precisions, recalls: recalls,
          fp_rates: fp_rates, tp_rates: tp_rates,
          pr_auc: pr_auc, roc_auc: roc_auc
        }
      end

      # Returns the predictive values hash (TP,FP, TN, FN) for a certain
      # threshold.
      def predictive_values(ground_truth, classification, threshold)
        tp = 0 # vandalism which is classified as vandalism
        fp = 0 # regular that is classified as vandalism
        tn = 0 # regular that is classified as regular
        fn = 0 # vandalism that is classified as regular

        ground_truth.each do |sample|
          values = sample[1]
          target_class = values[:class]

          key = :"#{values[:old_revision_id]}-#{values[:new_revision_id]}"
          # go on if annotated is not in classification
          next unless classification.key?(key)

          confidence = classification[key][:confidence]

          tp += 1 if Evaluator.true_positive?(target_class, confidence, threshold)  # True Positives
          fn += 1 if Evaluator.false_negative?(target_class, confidence, threshold) # False Negatives
          fp += 1 if Evaluator.false_positive?(target_class, confidence, threshold) # False Positives
          tn += 1 if Evaluator.true_negative?(target_class, confidence, threshold)  # True Negatives
        end

        { tp: tp, fp: fp, tn: tn, fn: fn }
      end

      # Returns whether the given confidence value represents a
      # true positive (TP) regarding the given target class and threshold.
      def self.true_positive?(target_class, confidence, threshold)
        target_class == Instances::VANDALISM_SHORT && confidence.to_f > threshold.to_f
      end

      # Returns whether the given confidence value represents a
      # true negative (TN) regarding the given target class and threshold.
      def self.true_negative?(target_class, confidence, threshold)
        target_class == Instances::REGULAR_SHORT && confidence.to_f < threshold.to_f
      end

      # Returns whether the given confidence value represents a
      # false positive (FP) regarding the given target class and threshold.
      def self.false_positive?(target_class, confidence, threshold)
        target_class == Instances::REGULAR_SHORT && confidence.to_f >= threshold.to_f
      end

      # Returns whether the given confidence value represents a
      # false negative (FN) regarding the given target class and threshold.
      def self.false_negative?(target_class, confidence, threshold)
        target_class == Instances::VANDALISM_SHORT && confidence.to_f <= threshold.to_f
      end

      # Returns a hash with performance parameters computed from given
      # TP, FP, TN, FN
      def performance_parameters(tp, fp, tn, fn)
        precision = (tp + fp).zero? ? 1.0 : tp.to_f / (tp.to_f + fp.to_f)
        recall    = (tp + fn).zero? ? 1.0 : tp.to_f / (tp.to_f + fn.to_f)
        fp_rate   = (fp + tn).zero? ? 1.0 : fp.to_f / (fp.to_f + tn.to_f)

        {
          precision: precision,
          recall: recall,
          fp_rate: fp_rate
        }
      end

      # Returns the calculated area under curve for given point values
      # x and y values has to be float arrays of the same length.
      def area_under_curve(x_values, y_values)
        unless x_values.count == y_values.count
          raise ArgumentError, 'x and y values must have the same length!'
        end

        sum = 0.0
        last_index = x_values.size - 1

        # trapezoid area formular: A = 1/2 * (b1 + b2) * h
        x_values.each_with_index do |x, index|
          break if index == last_index

          h = x_values[index + 1] - x
          b1 = y_values[index]
          b2 = y_values[index + 1]

          sum += 0.5 * (b1 + b2) * h
        end

        sum.abs
      end

      # Returns given value array sorted by first array (x_values)
      # Return value is a Hash { x: <x_values_sorted>, y: <y_values_sorted_by_x> }
      # start_value is added in front of arrays if set, e.g. {x: 0.0, y: 1.0}
      # end_values is added to end of arrays if set, e.g. {x: 1.0, y: 1.0 }
      #
      # @example
      #  evaluator.sort_curve_values(x, y, { x: 0.0, y: 0.0 }, { x: 1.0, y: 1.0 })
      #  #=>Hash { x: [0.0, *x, 1.0], y: [0.0, *y, 1.0] }
      def sort_curve_values(x_values, y_values, start_values = nil, end_values = nil)
        merge_sorted = x_values.each_with_index.map { |x, index| [x, y_values[index]] }
        merge_sorted = merge_sorted.sort_by { |values| [values[0], - values[1]] }.uniq

        x = merge_sorted.transpose[0]
        y = merge_sorted.transpose[1]

        start_values_set = start_values && (start_values.key?(:x) || start_values.key?(:y))
        end_values_set = end_values && (end_values.key?(:x) || end_values.key?(:y))

        if start_values_set
          unless x.first == start_values[:x] && y.first == start_values[:y]
            x.unshift(start_values[:x] || x.first)
            y.unshift(start_values[:y] || y.first)
          end
        end

        if end_values_set
          unless x.last == end_values[:x] && y.last == end_values[:y]
            x.push(end_values[:x] || x.last)
            y.push(end_values[:y] || y.last)
          end
        end

        { x: x, y: y }
      end

      # Returns the maximum precision recall pair
      def maximum_precision_recall(precisions, recalls)
        areas = precisions.each_with_index.map do |precision, index|
          [precision * recalls[index], index]
        end

        # remove arrays with NaN values
        areas.select! { |b| b.all? { |f| !f.to_f.nan? } }
        max_index = areas.sort.max[1]

        { precision: precisions[max_index], recall: recalls[max_index] }
      end

      # Creates the test corpus text file by classifying the configured test
      # samples. All sub steps (as creating the test arff file, etc.) are run
      # automatically if needed.
      def create_testcorpus_classification_file!(file_path, ground_truth_data)
        if ground_truth_data.nil?
          raise ArgumentError, 'Ground truth data hash is not allowed to be nil'
        end

        dataset = TestDataset.build!

        dir_name = File.dirname(file_path)
        FileUtils.mkdir_p(dir_name) unless Dir.exist?(dir_name)
        file = File.open(file_path, 'w')

        feature_names = dataset.attribute_names.map(&:upcase)[0...-2]
        header = ['OLDREVID', 'NEWREVID', 'C', 'CONF', *feature_names].join(' ')

        file.puts header

        dataset.to_m.to_a.each do |instance|
          features = instance[0...-3]
          old_revision_id = instance[-3].to_i
          new_revision_id = instance[-2].to_i
          ground_truth_class_name = Instances::CLASSES_SHORT[Instances::CLASSES.key(instance[-1])]

          classification = @classifier.classify(features, return_all_params: true)

          if classification[:class_index] == Instances::VANDALISM_CLASS_INDEX
            class_value = 1.0
          elsif classification[:class_index] == Instances::REGULAR_CLASS_INDEX
            class_value = 0.0
          else
            class_value = Features::MISSING_VALUE
          end

          confidence = classification[:confidence] || class_value

          must_be_inverted = @config.use_occ? && !!(@classifier.classifier_instance.options =~ /#{Instances::VANDALISM}/)
          confidence_value = must_be_inverted ? 1.0 - confidence : confidence
          features = features.join(' ').gsub(Float::NAN.to_s, Features::MISSING_VALUE).split

          file.puts [
            old_revision_id,
            new_revision_id,
            ground_truth_class_name,
            confidence_value,
            *features
          ].join(' ')
        end

        file.close
      end

      # Returns a hash comprising each feature's predictive values analysis for
      # different thresholds.
      # The Hash structure is the following one:
      # {
      #   feature_name_1:
      #    {
      #       0.0 => {fp: , fn: , tp: , tn: },
      #       ... => {fp: , fn: , tp: , tn: },
      #       1.0 => {fp: , fn: , tp: , tn: }
      #    },
      #   ...,
      #   feature_name_n:
      #    {
      #       0.0 => {fp: , fn: , tp: , tn: },
      #       ... => {fp: , fn: , tp: , tn: },
      #       1.0 => {fp: , fn: , tp: , tn: }
      #    },
      # }
      def feature_analysis(options = {})
        sample_count = options[:sample_count] || DEFAULT_SAMPLE_COUNT
        thresholds = (0.0..1.0).step(1.0 / (sample_count - 1)).to_a

        ground_truth_file_path = @config.test_corpus_ground_truth_file
        training_dataset = TrainingDataset.instances
        test_dataset = TestDataset.build!

        analysis = {}

        @config.features.each_with_index do |feature_name, index|
          puts "analyzing feature… '#{feature_name}'"

          dataset = filter_single_attribute(training_dataset, index)
          print ' | train classifier with feature data…'
          classifier = Classifier.new(dataset)
          print "done \n"

          classification = classification_data(classifier, test_dataset)
          ground_truth = ground_truth_hash(ground_truth_file_path)

          values = {}

          thresholds.each do |threshold|
            values[threshold] = predictive_values(ground_truth, classification, threshold)
          end

          analysis[feature_name] = values
        end

        analysis
      end

      # Returns a hash comprising the classifiers predictive values for using
      # all configured features for different thresholds.
      def full_analysis(options = {})
        sample_count = options[:sample_count] || DEFAULT_SAMPLE_COUNT
        thresholds = (0.0..1.0).step(1.0 / (sample_count - 1)).to_a

        ground_truth_file_path = @config.test_corpus_ground_truth_file

        puts 'train classifier…'
        classifier = Classifier.new

        test_dataset = TestDataset.build!

        puts 'computing classification…'
        classification = classification_data(classifier, test_dataset)
        ground_truth = ground_truth_hash(ground_truth_file_path)

        analysis = {}

        thresholds.each do |threshold|
          analysis[threshold] = predictive_values(ground_truth, classification, threshold)
        end

        print "done\n"
        analysis
      end

      private

      # Returns a dataset only holding the attribute at the given index.
      # Weka Unsupervised Attribute Remove filter is used.
      def filter_single_attribute(dataset, attribute_index)
        filter = Weka::Filters::Unsupervised::Attribute::Remove.new
        filter.use_options("-V -R #{attribute_index + 1},#{dataset.class_index + 1}")

        filtered = filter.filter(dataset)
        filtered.class_index = filtered.attributes_count - 1
        filtered
      end

      # Returns an array of classification confidences of the test corpus'
      # classification with the given classifier
      def classification_data(classifier, test_dataset)
        classification = {}

        test_dataset.to_m.to_a.each do |instance|
          features = instance[0...-3]

          old_revision_id = instance[-3].to_i
          new_revision_id = instance[-2].to_i

          params = classifier.classify(features, return_all_params: true)
          class_short_name = Instances::CLASSES_SHORT[params[:class_index]]

          must_be_inverted = @config.use_occ? && @classifier.classifier_instance.options !~ /#{Instances::VANDALISM}/
          confidence = must_be_inverted ? 1.0 - params[:confidence] : params[:confidence]

          classification[:"#{old_revision_id}-#{new_revision_id}"] = {
            old_revision_id: old_revision_id,
            new_revision_id: new_revision_id,
            class: class_short_name,
            confidence: confidence
          }
        end

        classification
      end

      # Returns a hash for classification data from given classification file
      def classification_hash(classification_file)
        file = File.read(classification_file)
        classification_samples = file.lines.to_a
        classification_samples.shift # remove header line

        classification = {}

        classification_samples.each do |line|
          line_parts = line.split(' ')

          old_revision_id = line_parts[0].to_i
          new_revision_id = line_parts[1].to_i
          class_short = line_parts[2]
          confidence = line_parts[3].to_f

          classification[:"#{old_revision_id}-#{new_revision_id}"] = {
            old_revision_id: old_revision_id,
            new_revision_id: new_revision_id,
            class: class_short,
            confidence: confidence
          }
        end

        classification
      end

      # Returns a hash for classification data from given ground truth file
      def ground_truth_hash(ground_truth_file)
        file = File.read(ground_truth_file)
        ground_truth_samples = file.lines.to_a

        ground_truth = {}

        ground_truth_samples.each do |line|
          line_parts = line.split(' ')

          old_revision_id = line_parts[0].to_i
          new_revision_id = line_parts[1].to_i
          class_short = line_parts[2]

          ground_truth[:"#{old_revision_id}-#{new_revision_id}"] = {
            old_revision_id: old_revision_id,
            new_revision_id: new_revision_id,
            class: class_short
          }
        end

        ground_truth
      end

      # Cross validates classifier over full dataset with <fold>-fold cross
      # validation
      def cross_validate_all_instances(fold)
        @classifier_instance.cross_validate(folds: fold)
      rescue => error
        raise "Error while cross validation: #{error}"
      end

      # Cross validates classifier over equally distributed dataset with
      # <fold>-fold cross validation
      def cross_validate_equally_distributed(fold)
        dirname = @config.output_base_directory
        FileUtils.mkdir(dirname) unless Dir.exist?(dirname)

        file_name = 'cross_validation_eq_distr.txt'
        file_path = File.join(dirname, file_name)

        puts "Writing to #{file_path}…"
        result_file = File.open(file_path, 'a')

        begin
          time = Time.now.strftime('%Y-%m-%d %H:%M')
          type = @config.classifier_type
          options = @config.classifier_options || 'default'
          result_file.puts "\nCROSS VALIDATION - #{fold} fold (Classifier: #{type}, options: #{options} ) | #{time}"
          result_file.puts "Features: \n\t#{@config.features.join("\n\t")}\n\n"

          evaluations = []

          times = 10

          # run n times validation
          (1..times).each do |i|
            uniform_dataset = TrainingDataset.balanced_instances

            print "\rcross validate dataset  (equally distributed)… #{i}/#{times} | instances: #{uniform_dataset.size}"
            @classifier_instance.train_with_instances(uniform_dataset)
            evaluations << @classifier_instance.cross_validate(folds: fold)

            if (i % (times / 10)).zero?
              print_evaluation_data(evaluations, result_file, i)
            end
          end

          #evaluation_data_of(evaluations)
          evaluations
        rescue => error
          raise "Error while cross validation for equally distributed instances: #{error}"
        ensure
          result_file.close
          puts "\nThe evaluation results has been saved to #{file_path}"
        end
      end

      # Returns the evaluation data average value hash of the given evaluations.
      def evaluation_data_of(evaluations)
        class_index = Instances::VANDALISM_CLASS_INDEX
        total_count = evaluations.count.to_f

        recall = evaluations.reduce(0.0) { |result, sample| result + sample.recall(class_index) } / total_count
        precision = evaluations.reduce(0.0) { |result, sample| result + sample.precision(class_index) } / total_count
        area_under_prc = evaluations.reduce(0.0) { |result, sample| result + sample.area_under_prc(class_index) } / total_count

        {
          precision: precision,
          recall: recall,
          area_under_prc: area_under_prc
        }
      end

      # Prints data to file
      def print_evaluation_data(evaluations, file, index)
        data = evaluation_data_of(evaluations)
        file.puts "#{index}\tprecision: #{data[:precision]} | recall: #{data[:recall]} | Area under PRC: #{data[:area_under_prc]}"
      end
    end
  end
end

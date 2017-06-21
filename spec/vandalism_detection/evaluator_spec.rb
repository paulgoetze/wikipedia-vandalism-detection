require 'spec_helper'

describe Wikipedia::VandalismDetection::Evaluator do
  let(:vandalism) { Instances::VANDALISM_SHORT }
  let(:regular)   { Instances::REGULAR_SHORT }

  let(:sample_count) { 10 }

  before do
    use_test_configuration
    @config = test_config

    @build_dir                = @config.output_base_directory
    @test_arff_file           = @config.test_output_arff_file
    @training_arff_file       = @config.training_output_arff_file
    @test_classification_file = @config.test_output_classification_file
  end

  after do
    # remove training arff file
    if File.exist?(@training_arff_file)
      File.delete(@training_arff_file)
      directory = File.dirname(@training_arff_file)
      FileUtils.rm_r(directory)
    end

    # remove test arff file
    if File.exist?(@test_arff_file)
      File.delete(@test_arff_file)
      directory = File.dirname(@test_arff_file)
      FileUtils.rm_r(directory)
    end

    # remove classification.txt
    if File.exist?(@test_classification_file)
      File.delete(@test_classification_file)
      directory = File.dirname(@test_classification_file)
      File.rm_r(directory)
    end

    # remove output base directory
    FileUtils.rm_r(@build_dir) if Dir.exist?(@build_dir)
  end

  describe '#initialize' do
    it 'raises an ArgumentError if classifier argument is not a Classfier' do
      expect { Evaluator.new('') }.to raise_error ArgumentError
    end

    it 'does not raise an error when a classifier is passed' do
      classifier = Classifier.new
      expect { Evaluator.new(classifier) }.not_to raise_error
    end
  end

  let(:classifier) { Classifier.new }
  let(:evaluator) { Evaluator.new(classifier) }

  describe '#test_performance_curves' do
    let(:classification) do
      {
        '1-2': {
          old_revision_id: 1,
          new_revision_id: 2,
          class: 'R',
          confidence: 0.0
        },
        '2-3': {
          old_revision_id: 2,
          new_revision_id: 3,
          class: 'R',
          confidence: 0.3
        },
        '3-4': {
          old_revision_id: 3,
          new_revision_id: 4,
          class: 'V',
          confidence: 0.8
        },
        '4-5': {
          old_revision_id: 4,
          new_revision_id: 5,
          class: 'V',
          confidence: 1.0
        }
      }
    end

    # ground truth has one sample more to represent fall-out samples while
    # feature calculation (e.g. redirects are not considered)
    let(:ground_truth) do
      {
        '0-1': { # this is a sample that is not used!
          old_revision_id: 0,
          new_revision_id: 1,
          class: 'R'
        },
        '1-2': {
          old_revision_id: 1,
          new_revision_id: 2,
          class: 'R'
        },
        '2-3': {
          old_revision_id: 2,
          new_revision_id: 3,
          class: 'V'
        },
        '3-4': {
          old_revision_id: 3,
          new_revision_id: 4,
          class: 'R'
        },
        '4-5': {
          old_revision_id: 4,
          new_revision_id: 5,
          class: 'V'
        }
      }
    end

    let(:curve_data) do
      evaluator.test_performance_curves(
        ground_truth,
        classification,
        sample_count
      )
    end

    it 'returns a Hash' do
      expect(curve_data).to be_a Hash
    end

    %i[
      recalls
      precisions
      fp_rates
      tp_rates
      pr_auc
      roc_auc
    ].each do |attribute|
      it "returns a Hash including #{attribute}" do
        expect(curve_data).to have_key(attribute)
      end
    end

    describe '#predictive_values' do
      let(:threshold) { 0.5 }
      let(:predictive_values) do
        evaluator.predictive_values(ground_truth, classification, threshold)
      end

      it 'returns a Hash' do
        expect(predictive_values).to be_a Hash
      end

      [
        { threshold: 0.0, result: { tp: 2, fp: 2, tn: 0, fn: 0 } },
        { threshold: 0.3, result: { tp: 1, fp: 1, tn: 1, fn: 1 } },
        { threshold: 0.5, result: { tp: 1, fp: 1, tn: 1, fn: 1 } },
        { threshold: 0.8, result: { tp: 1, fp: 1, tn: 1, fn: 1 } },
        { threshold: 0.9, result: { tp: 1, fp: 0, tn: 2, fn: 1 } },
        { threshold: 1.0, result: { tp: 0, fp: 0, tn: 2, fn: 2 } }
      ].each do |values|
        it "returns the right values for threshold #{values[:threshold]}" do
          predictive_values = evaluator.predictive_values(
            ground_truth,
            classification,
            values[:threshold]
          )

          expect(predictive_values).to eq values[:result]
        end
      end
    end

    describe '#sort_curve_values' do
      let(:x) { [0.7, 0.4, 0.8, 0.4, 0.7] }
      let(:y) { [0.6, 0.8, 0.2, 0.6, 0.6] }

      let(:x_sorted) { [0.4, 0.4, 0.7, 0.8] }
      let(:y_sorted) { [0.8, 0.6, 0.6, 0.2] }

      it 'returns the unique sorted input values' do
        hash = { x: x_sorted, y: y_sorted }
        sorted = evaluator.sort_curve_values(x, y)

        expect(sorted).to eq hash
      end

      it 'adds start values if given' do
        start_values = { x: -1.0, y: -2.0 }
        hash = {
          x: x_sorted.unshift(start_values[:x]),
          y: y_sorted.unshift(start_values[:y])
        }

        sorted = evaluator.sort_curve_values(x, y, start_values)

        expect(sorted).to eq hash
      end

      it 'adds x start value if only one value given' do
        start_values = { x: -1.0 }
        hash = {
          x: x_sorted.unshift(start_values[:x]),
          y: y_sorted.unshift(y_sorted.first)
        }

        sorted = evaluator.sort_curve_values(x, y, start_values)

        expect(sorted).to eq hash
      end

      it 'adds y start value if only one value given' do
        start_values = { y: -2.0 }
        hash = {
          x: x_sorted.unshift(x_sorted.first),
          y: y_sorted.unshift(start_values[:y])
        }

        sorted = evaluator.sort_curve_values(x, y, start_values)

        expect(sorted).to eq hash
      end

      it 'adds end values if given' do
        end_values = { x: -1.0, y: -2.0 }
        hash = {
          x: x_sorted.push(end_values[:x]),
          y: y_sorted.push(end_values[:y])
        }

        sorted = evaluator.sort_curve_values(x, y, nil, end_values)

        expect(sorted).to eq hash
      end

      it 'adds y end values if only one value is given' do
        end_values = { y: -2.0 }
        hash = {
          x: x_sorted.push(x_sorted.last),
          y: y_sorted.push(end_values[:y])
        }

        sorted = evaluator.sort_curve_values(x, y, nil, end_values)

        expect(sorted).to eq hash
      end

      it 'adds x end values if only one value is given' do
        end_values = { x: -1.0 }
        hash = {
          x: x_sorted.push(end_values[:x]),
          y: y_sorted.push(y_sorted.last)
        }

        sorted = evaluator.sort_curve_values(x, y, nil, end_values)

        expect(sorted).to eq hash
      end
    end

    describe '#area_under_curve' do
      let(:pr_auc) do
        evaluator.area_under_curve(
          curve_data[:precisions],
          curve_data[:precisions]
        )
      end

      let(:roc_auc) do
        evaluator.area_under_curve(
          curve_data[:fp_rates],
          curve_data[:tp_rates]
        )
      end

      it 'returns a numeric value for pr_auc' do
        expect(pr_auc).to be_a Numeric
      end

      it 'returns a numeric value between 0.0 & 1.0 for pr_auc' do
        is_between_zero_and_one = (pr_auc >= 0.0 && pr_auc <= 1.0)
        expect(is_between_zero_and_one).to be true
      end

      it 'returns a numeric value for roc_auc' do
        expect(roc_auc).to be_a Numeric
      end

      it 'returns a numeric value between 0.0 & 1.0 for roc_auc' do
        is_between_zero_and_one = roc_auc >= 0.0 && roc_auc <= 1.0
        expect(is_between_zero_and_one).to be true
      end

      it 'returns the right values' do
        x = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
        y = [1.0, 0.8, 0.6, 0.4, 0.2, 0.0]
        auc = 0.5

        expect(evaluator.area_under_curve(x, y)).to eq auc
      end
    end
  end

  describe '#create_testcorpus_classification_file!' do
    let(:ground_truth) do
      { # see resources file ground_truth.csv
        '0-1': { # this is a sample that is not used!
          old_revision_id: 0,
          new_revision_id: 1,
          class: 'R'
        },
        '307084144-326873205': {
          old_revision_id: 307_084_144,
          new_revision_id: 326_873_205,
          class: 'R'
        },
        '326471754-326978767': {
          old_revision_id: 326_471_754,
          new_revision_id: 326_978_767,
          class: 'V'
        },
        '328774035-328774110': {
          old_revision_id: 328_774_035,
          new_revision_id: 328_774_110,
          class: 'R'
        }
      }
    end

    it 'raises an argument error if ground_truth param is nil' do
      expect { evaluator.create_testcorpus_classification_file!('blah', nil) }
        .to raise_error ArgumentError
    end

    it 'creates a classification file in the base output directory' do
      expect(File.exist?(@test_classification_file)).to be false
      evaluator.create_testcorpus_classification_file!(@test_classification_file, ground_truth)
      expect(File.exist?(@test_classification_file)).to be true
    end

    it 'creates a file with an appropriate header' do
      evaluator.create_testcorpus_classification_file!(@test_classification_file, ground_truth)
      content = File.open(@test_classification_file, 'r')

      instances = Weka::Core::Instances.from_arff(@test_arff_file)
      features = instances.attribute_names.map(&:upcase)[0...-2]
      proposed_header = ['OLDREVID', 'NEWREVID', 'C', 'CONF', *features]
      header = content.lines.first.split(' ')

      expect(header).to eq proposed_header
    end

    it 'creates a file with an appropriate number of lines' do
      evaluator.create_testcorpus_classification_file!(@test_classification_file, ground_truth)
      content = File.open(@test_classification_file, 'r')

      samples_count = Weka::Core::Instances.from_arff(@test_arff_file).size

      lines = content.lines.to_a
      lines.shift # remove header
      expect(lines.count).to eq samples_count
    end

    it 'has the short class names as class value' do
      evaluator.create_testcorpus_classification_file!(@test_classification_file, ground_truth)
      content = File.open(@test_classification_file, 'r')

      lines = content.lines.to_a
      lines.shift # remove header
      short_classes   = Instances::CLASSES_SHORT
      vandalism_index = Instances::VANDALISM_CLASS_INDEX
      regular_index   = Instances::REGULAR_CLASS_INDEX
      missing_index   = Instances::NOT_KNOWN_INDEX

      names = [
        short_classes[regular_index],
        short_classes[vandalism_index],
        short_classes[missing_index]
      ]

      lines.each do |line|
        class_name = line.split[2]
        expect(names).to include class_name
      end
    end
  end

  describe '#evaluate_testcorpus_classification' do
    describe 'exceptions' do
      it 'raises an error unless a ground thruth file is configured' do
        config = test_config
        config.instance_variable_set :@test_corpus_ground_truth_file, nil
        use_configuration(config)

        classifier = Classifier.new
        evaluator = Evaluator.new(classifier)

        expect { evaluator.evaluate_testcorpus_classification }.to raise_error \
          Wikipedia::VandalismDetection::GroundTruthFileNotConfiguredError
      end

      it 'raises an error unless the ground thruth file can be found' do
        config = test_config
        config.instance_variable_set(:@test_corpus_ground_truth_file, 'false-file-name.txt')
        use_configuration(config)

        classifier = Classifier.new
        evaluator = Evaluator.new(classifier)

        expect { evaluator.evaluate_testcorpus_classification }.to raise_error \
          Wikipedia::VandalismDetection::GroundTruthFileNotFoundError
      end
    end

    it 'returns a performance values Hash' do
      values = evaluator.evaluate_testcorpus_classification(sample_count: sample_count)
      expect(values).to be_a Hash
    end

    %i[
      fp_rates
      tp_rates
      precisions
      recalls
      pr_auc
      roc_auc
      total_precision
      total_recall
    ].each do |attribute|
      it "returns a performance values Hash with property'#{attribute}'" do
        values = evaluator.evaluate_testcorpus_classification(sample_count: sample_count)
        expect(values[attribute]).to_not be_nil
      end
    end

    it 'runs the classification file creation' do
      expect(File.exist?(@test_classification_file)).to be false
      evaluator.evaluate_testcorpus_classification
      expect(File.exist?(@test_classification_file)).to be true
    end

    it 'overwrites the old classification file' do
      config = test_config

      config.instance_variable_set(:@features, ['comment length'])
      use_configuration(config)

      classifier = Classifier.new
      evaluator = Evaluator.new(classifier)

      evaluator.evaluate_testcorpus_classification
      content_old = File.read(@test_classification_file)

      config.instance_variable_set(:@features, ['anonymity'])
      use_configuration(config)

      classifier = Classifier.new
      evaluator = Evaluator.new(classifier)

      evaluator.evaluate_testcorpus_classification
      content_new = File.read(@test_classification_file)

      expect(content_old).to_not eq content_new
    end
  end

  describe '#cross_validate' do
    it 'returns an evaluation object' do
      evaluation = evaluator.cross_validate
      expect(evaluation).to be_a Java::WekaClassifiers::Evaluation
    end

    it 'can cross validates the classifier' do
      expect { evaluator.cross_validate }.not_to raise_error
    end

    it 'can cross validates the classifier with equally distributed samples' do
      expect { evaluator.cross_validate(equally_distributed: true) }
        .not_to raise_error
    end
  end

  describe '#curve_data' do
    describe 'all samples' do
      let(:data) { evaluator.curve_data }

      it 'returns a Hash' do
        expect(data).to be_a Hash
      end

      it 'includes precision curve data' do
        expect(data[:precision]).to be_an Array
      end

      it 'includes recall curve data' do
        expect(data[:recall]).to be_an Array
      end

      it 'includes area_under_prc data' do
        expect(data[:area_under_prc]).to be_a Numeric
      end

      it 'has non-empty :precision Array contents' do
        expect(data[:precision]).to_not be_empty
      end

      it 'has non-empty :recall Array contents' do
        expect(data[:recall]).to_not be_empty
      end
    end

    describe 'equally distributed samples' do
      let(:data) { evaluator.curve_data(equally_distributed: true) }

      it 'returns a Hash' do
        expect(data).to be_a Hash
      end

      it 'includes precision curve data' do
        expect(data[:precision]).to be_a Array
      end

      it 'includes recall curve data' do
        expect(data[:recall]).to be_a Array
      end

      it 'includes area_under_prc data' do
        expect(data[:area_under_prc]).to be_a Numeric
      end

      it 'has non-empty :precision Array contents' do
        expect(data[:precision]).to_not be_empty
      end

      it 'has non-empty :recall Array contents' do
        expect(data[:recall]).to_not be_empty
      end
    end
  end

  describe '#feature_analysis' do
    it 'returns a hash' do
      analysis = evaluator.feature_analysis(sample_count: 100)
      expect(analysis).to be_a Hash
    end

    it 'returns a hash with feature count size' do
      analysis = evaluator.feature_analysis(sample_count: 100)
      expect(analysis.count).to eq @config.features.count
    end

    it 'returns a hash with sample count number of data hashes' do
      sample_count = 5
      analysis = evaluator.feature_analysis(sample_count: sample_count)

      analysis.each_value do |threshold_hash|
        expect(threshold_hash.count).to eq sample_count
      end
    end

    it 'returns the four predictive values in each features threshold hash' do
      analysis = evaluator.feature_analysis
      threshold_hash = analysis[@config.features.first][0.0]

      expect(threshold_hash).to have_key(:fp)
      expect(threshold_hash).to have_key(:fn)
      expect(threshold_hash).to have_key(:tp)
      expect(threshold_hash).to have_key(:tn)
    end
  end

  describe '#full_analysis' do
    it 'returns a hash' do
      analysis = evaluator.full_analysis(sample_count: 100)
      expect(analysis).to be_a Hash
    end

    it 'returns a hash with smaple count number of threshold hashes' do
      sample_count = 5
      analysis = evaluator.full_analysis(sample_count: sample_count)
      expect(analysis.count).to eq sample_count
    end

    it 'returns the four predictive values in each features threshold hash' do
      analysis = evaluator.full_analysis
      threshold_hash = analysis[0.0]

      expect(threshold_hash).to have_key(:fp)
      expect(threshold_hash).to have_key(:fn)
      expect(threshold_hash).to have_key(:tp)
      expect(threshold_hash).to have_key(:tn)
    end
  end

  describe '#true_positive?' do
    let(:threshold) { 0.7 }

    it 'returns true if confidence > threshold regarding ground truth "V"' do
      true_pos = Evaluator.true_positive?(vandalism, threshold + 0.1, threshold)
      expect(true_pos).to be true
    end

    it 'returns false if confidence < threshold regarding ground truth "V"' do
      true_pos = Evaluator.true_positive?(vandalism, threshold - 0.2, threshold)
      expect(true_pos).to be false
    end

    it 'returns false for same confidence & threshold if ground truth is "V"' do
      true_pos = Evaluator.true_positive?(vandalism, threshold, threshold)
      expect(true_pos).to be false
    end

    it 'returns false if confidence > threshold regarding ground truth "R"' do
      true_pos = Evaluator.true_positive?(regular, threshold + 0.1, threshold)
      expect(true_pos).to be false
    end

    it 'returns false if confidence < threshold regarding ground truth "R"' do
      true_pos = Evaluator.true_positive?(regular, threshold - 0.1, threshold)
      expect(true_pos).to be false
    end
  end

  describe '#true_negative?' do
    let(:threshold) { 0.7 }

    it 'returns true if confidence < threshold regarding ground truth "R"' do
      true_neg = Evaluator.true_negative?(regular, threshold - 0.1, threshold)
      expect(true_neg).to be true
    end

    it 'returns false if confidence > threshold regarding ground truth "R"' do
      true_neg = Evaluator.true_negative?(regular, threshold + 0.1, threshold)
      expect(true_neg).to be false
    end

    it 'returns false for same confidence & threshold if ground truth is "R"' do
      true_neg = Evaluator.true_negative?(regular, threshold, threshold)
      expect(true_neg).to be false
    end

    it 'returns false if confidence < threshold regarding ground truth "V"' do
      true_neg = Evaluator.true_negative?(vandalism, threshold - 0.1, threshold)
      expect(true_neg).to be false
    end

    it "returns false if confidence > threshold regarding ground truth 'V'" do
      expect(Evaluator.true_negative?(vandalism, 0.8, threshold)).to be false
    end
  end

  describe '#false_positive?' do
    let(:threshold) { 0.7 }

    it 'returns true if confidence > threshold regarding ground truth "R"' do
      false_pos = Evaluator.false_positive?(regular, threshold + 0.1, threshold)
      expect(false_pos).to be true
    end

    it 'returns false if confidence < threshold regarding ground truth "R"' do
      false_pos = Evaluator.false_positive?(regular, threshold - 0.1, threshold)
      expect(false_pos).to be false
    end

    it 'returns true for same confidence & threshold if ground truth is "R"' do
      false_pos = Evaluator.false_positive?(regular, threshold, threshold)
      expect(false_pos).to be true
    end

    it 'returns false if confidence > threshold regarding ground truth "V"' do
      false_pos = Evaluator.false_positive?(vandalism, threshold + 0.1, threshold)
      expect(false_pos).to be false
    end

    it 'returns false if confidence < threshold regarding ground truth "V"' do
      false_pos = Evaluator.false_positive?(vandalism, threshold - 0.1, threshold)
      expect(false_pos).to be false
    end
  end

  describe '#false_negative?' do
    let(:threshold) { 0.7 }

    it 'returns true if confidence < threshold regarding ground truth "V"' do
      false_neg = Evaluator.false_negative?(vandalism, threshold - 0.1, threshold)
      expect(false_neg).to be true
    end

    it 'returns false if confidence > threshold regarding ground truth "V"' do
      false_neg = Evaluator.false_negative?(vandalism, threshold + 0.1, threshold)
      expect(false_neg).to be false
    end

    it 'returns true for same confidence & threshold if ground truth is "V"' do
      false_neg = Evaluator.false_negative?(vandalism, threshold, threshold)
      expect(false_neg).to be true
    end

    it 'returns false if confidence < threshold regarding ground truth "R"' do
      false_neg = Evaluator.false_negative?(regular, threshold - 0.1, threshold)
      expect(false_neg).to be false
    end

    it 'returns false if confidence > threshold regarding ground truth "R"' do
      false_neg = Evaluator.false_negative?(regular, threshold + 0.1, threshold)
      expect(false_neg).to be false
    end
  end
end

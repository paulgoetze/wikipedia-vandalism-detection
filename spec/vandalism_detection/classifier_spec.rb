require 'spec_helper'

describe Wikipedia::VandalismDetection::Classifier do
  before do
    use_test_configuration
    @config = test_config
  end

  after do
    arff_file = @config.training_output_arff_file
    build_dir = @config.output_base_directory

    if File.exist?(arff_file)
      File.delete(arff_file)
      directory = File.dirname(arff_file)
      FileUtils.rm_r(directory)
    end

    FileUtils.rm_r(build_dir) if Dir.exist?(build_dir)
  end

  it 'loads the configured classifier while instanciating' do
    classifier_name = @config.classifier_type
    class_type = "Weka::Classifiers::#{classifier_name}".constantize

    expect(subject.classifier_instance).to be_a class_type
  end

  it 'loads the configured classifier with given dataset' do
    classifier_name = @config.classifier_type
    class_type      = "Weka::Classifiers::#{classifier_name}".constantize
    dataset         = Instances.empty_for_feature('anonymity')
    dataset.add_instance([1.0, Instances::REGULAR])

    classifier = Classifier.new(dataset)

    expect(classifier.classifier_instance).to be_a class_type
    expect(classifier.dataset).to be dataset
  end

  it 'raises an error if no classifier is configured' do
    config = test_config
    config.instance_variable_set(:@classifier_type, nil)
    use_configuration(config)

    expect { Classifier.new }.to raise_error \
      Wikipedia::VandalismDetection::ClassifierNotConfiguredError
  end

  it 'raises an error if an unknown classifier is configured' do
    config = test_config
    config.instance_variable_set(:@classifier_type, 'Unknown Classifier')
    use_configuration(config)

    expect { Classifier.new }.to raise_error \
      Wikipedia::VandalismDetection::ClassifierUnknownError
  end

  it 'raises an error if no features are configured' do
    config = test_config
    config.instance_variable_set :@features, []
    use_configuration(config)

    expect { Classifier.new }.to raise_error \
      Wikipedia::VandalismDetection::FeaturesNotConfiguredError
  end

  it 'loads & trains the classifier with balanced dataset if configured' do
    config = test_config
    config.instance_variable_set(:@training_data_options, 'balanced')
    use_configuration(config)

    classifier = Classifier.new

    # 2 vandalism, 2 regular, see resources/corpora/training/annotations.csv
    expect(classifier.dataset.size).to eq 4
  end

  it 'loads & trains the classifier with unbalanced dataset if configured' do
    config = test_config
    config.instance_variable_set(:@training_data_options, 'unbalanced')
    use_configuration(config)

    classifier = Classifier.new
    dataset = classifier.dataset

    vandalism_class_index = Instances::VANDALISM_CLASS_INDEX
    regular_class_index   = Instances::REGULAR_CLASS_INDEX

    vandalism_count = dataset.instances.reduce(0) do |count, instance|
      count += 1 if instance.class_value.to_i == vandalism_class_index
      count
    end

    regular_count = dataset.instances.reduce(0) do |count, instance|
      count += 1 if instance.class_value.to_i == regular_class_index
      count
    end

    # 2 vandalism, 4 regular, see resources/corpora/training/annotations.csv
    expect(dataset.size).to eq 6
    expect(regular_count).to eq 4
    expect(vandalism_count).to eq 2
  end

  it 'loads & trains the classifier with oversampled dataset if configured' do
    config = test_config
    config.instance_variable_set(:@training_data_options, 'oversampled')
    use_configuration(config)

    classifier = Classifier.new
    dataset = classifier.dataset

    vandalism_class_index = Instances::VANDALISM_CLASS_INDEX
    regular_class_index   = Instances::REGULAR_CLASS_INDEX

    vandalism_count = dataset.instances.reduce(0) do |count, instance|
      count += 1 if instance.class_value.to_i == vandalism_class_index
      count
    end

    regular_count = dataset.instances.reduce(0) do |count, instance|
      count += 1 if instance.class_value.to_i == regular_class_index
      count
    end

    # 4 vandalism, 4 regular, due to SMOTE oversampling
    expect(dataset.size).to eq 8
    expect(regular_count).to eq 4
    expect(vandalism_count).to eq 4
  end

  it 'loads & trains the classifier with customized oversampled dataset if configured' do
    config = test_config
    options = 'oversampled -p 200 -u false'
    config.instance_variable_set(:@training_data_options, options)
    use_configuration(config)

    classifier = Classifier.new
    dataset = classifier.dataset

    vandalism_class_index = Instances::VANDALISM_CLASS_INDEX
    regular_class_index   = Instances::REGULAR_CLASS_INDEX

    vandalism_count = dataset.instances.reduce(0) do |count, instance|
      count += 1 if instance.class_value.to_i == vandalism_class_index
      count
    end

    regular_count = dataset.instances.reduce(0) do |count, instance|
      count += 1 if instance.class_value.to_i == regular_class_index
      count
    end

    # 2 + 200 % = 6 vandalism, 4 regular, due to SMOTE oversampling without
    # undersampling
    expect(dataset.size).to eq 10
    expect(regular_count).to eq 4
    expect(vandalism_count).to eq 6
  end

  describe 'attribute readers' do
    %i[classifier_instance evaluator dataset].each do |attribute|
      it "has a readable #{name} attribute" do
        expect(subject).to respond_to attribute
      end
    end

    it 'returns an Evaluator instance from attribute #evaluator' do
      expect(subject.evaluator).to be_an Evaluator
    end
  end

  describe '#classify' do
    let(:edit) { build(:edit) }

    let(:features) do
      calculator = Wikipedia::VandalismDetection::FeatureCalculator.new
      calculator.calculate_features_for(edit)
    end

    it 'raises an error if the argument is no Edit or feature Array' do
      expect { subject.classify('data') }.to raise_error ArgumentError
    end

    it 'takes an Edit as argument' do
      expect { subject.classify(edit) }.not_to raise_error ArgumentError
    end

    it 'takes a feature Array as argument' do
      expect { subject.classify(features) }.not_to raise_error ArgumentError
    end

    it 'returns the same value for both edit and features as argument' do
      confidence_from_edit = subject.classify(edit)
      confidence_from_features = subject.classify(features)

      expect(confidence_from_edit).to eq confidence_from_features
    end

    it 'returns a Numeric value as the confidence of vandalism class' do
      confidence = subject.classify(features)
      expect(confidence).to be_a Numeric
    end

    it 'returns a confidence between 0.0 and 1.0' do
      confidence = subject.classify(features)
      is_between_zero_and_one = confidence <= 1.0 && confidence >= 0.0
      expect(is_between_zero_and_one).to be true
    end

    it 'returns -1.0 if features cannot be computed from the edit' do
      allow_any_instance_of(Wikipedia::VandalismDetection::FeatureCalculator)
        .to receive(:calculate_features_for)
        .and_return([])

      confidence = subject.classify(edit)

      expect(confidence).to eq(-1.0)
    end

    describe 'with option ":return_all_params = true"' do
      it 'returns a hash' do
        parameters = subject.classify(features, return_all_params: true)
        expect(parameters).to be_a Hash
      end

      %i[confidence class_index].each do |key|
        it "returns a hash with key :#{key}" do
          results = subject.classify(features, return_all_params: true)
          expect(results.keys).to include key
        end
      end

      it 'returns a class_index value of 0 or 1' do
        results = subject.classify(features, return_all_params: true)
        class_index = results[:class_index]
        is_one_or_zero = class_index == 0 || class_index == 1

        expect(is_one_or_zero).to be true
      end

      it 'returns an confidence value that is between 0.0 and 1.0' do
        results = subject.classify(features, return_all_params: true)
        confidence = results[:confidence]
        between_zero_and_one = confidence <= 1.0 && confidence >= 0.0

        expect(between_zero_and_one).to be true
      end
    end

    it 'raises an argument error if given features are an empty array' do
      expect { subject.classify([]) }.to raise_error ArgumentError
    end

    it 'it handles NaN return values (i.e. is not implemented)' do
      config = test_config
      config.instance_variable_set(:@classifier_type, 'Meta::OneClassClassifier')
      config.instance_variable_set(:@classifier_options, "-tcl #{Instances::VANDALISM}")

      use_configuration(config)

      # add more test instances because instances number must higher than cross
      # validation fold
      instances = TrainingDataset.instances.to_m.to_a
      dataset = Instances.empty

      vandalism_index = Instances::VANDALISM_CLASS_INDEX
      regular_index = Instances::REGULAR_CLASS_INDEX

      [vandalism_index, regular_index].each do |index|
        instances.each do |row|
          values = row[0..-2]
          class_value = Instances::CLASSES[index]
          dataset.add_instance([*values, class_value])
        end
      end

      classifier = Classifier.new(dataset)
      results = classifier.classify(features, return_all_params: true)
      expect(results).to be_a Hash
    end

    it 'handles one class classification with "regular" as target class' do
      config = test_config
      config.instance_variable_set(:@classifier_type, 'Meta::OneClassClassifier')
      config.instance_variable_set(:@classifier_options, "-tcl #{Instances::REGULAR}")

      use_configuration(config)

      # add more test instances because instances number must higher than cross
      # validation fold
      instances = TrainingDataset.instances.to_m.to_a
      dataset = Instances.empty

      vandalism_index = Instances::VANDALISM_CLASS_INDEX
      regular_index = Instances::REGULAR_CLASS_INDEX

      [vandalism_index, regular_index].each do |index|
        instances.each do |row|
          values = row[0..-2]
          class_value = Instances::CLASSES[index]
          dataset.add_instance([*values, class_value])
        end
      end

      classifier = Classifier.new(dataset)
      results = classifier.classify(features, return_all_params: true)

      expect(results).to be_a Hash
    end
  end

  describe '#cross_validate' do
    it 'returns an Evaluation object' do
      evaluation = subject.cross_validate
      expect(evaluation).to be_a Java::WekaClassifiers::Evaluation
    end

    context 'with option "equally distributed"' do
      it 'returns an array of Evaluation objects' do
        evaluations = subject.cross_validate(equally_distributed: true)

        evaluations.each do |evaluation|
          expect(evaluation).to be_a Java::WekaClassifiers::Evaluation
        end
      end
    end
  end
end

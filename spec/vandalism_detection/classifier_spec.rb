require 'spec_helper'

describe Wikipedia::VandalismDetection::Classifier do

  before do
    use_test_configuration
    @config = test_config

    @classifier = Wikipedia::VandalismDetection::Classifier.new
  end

  after do
    arff_file = @config.training_output_arff_file
    build_dir = @config.output_base_directory

    if File.exists?(arff_file)
      File.delete(arff_file)
      FileUtils.rm_r(File.dirname arff_file)
    end

    if Dir.exists?(build_dir)
      FileUtils.rm_r(build_dir)
    end
  end

  it "loads the configured classifier while instanciating" do
    classifier_name =  @config.classifier_type
    class_type = "Weka::Classifiers::#{classifier_name}::Base".constantize

    expect(@classifier.classifier_instance).to be_a class_type
  end

  it "loads the configured classifier with given dataset" do
    classifier_name =  @config.classifier_type
    class_type = "Weka::Classifiers::#{classifier_name}::Base".constantize
    dataset = Wikipedia::VandalismDetection::Instances.empty_for_feature('anonymity')
    dataset.add_instance([1.0, Wikipedia::VandalismDetection::Instances::REGULAR])

    classifier = Wikipedia::VandalismDetection::Classifier.new(dataset)

    expect(classifier.classifier_instance).to be_a class_type
    expect(classifier.dataset).to be dataset
  end

  it "raises an error if no classifier is configured" do
    config = test_config
    config.instance_variable_set :@classifier_type, nil
    use_configuration(config)

    expect { Wikipedia::VandalismDetection::Classifier.new }.to raise_error \
      Wikipedia::VandalismDetection::ClassifierNotConfiguredError
  end

  it "raises an error if an unknown classifier is configured" do
    config = test_config
    config.instance_variable_set :@classifier_type, "Unknown Classifier"
    use_configuration(config)

    expect { Wikipedia::VandalismDetection::Classifier.new }.to raise_error \
      Wikipedia::VandalismDetection::ClassifierUnknownError
  end

  it "raises an error if no features are configured" do
    config = test_config
    config.instance_variable_set :@features, []
    use_configuration(config)

    expect { Wikipedia::VandalismDetection::Classifier.new }.to raise_error \
      Wikipedia::VandalismDetection::FeaturesNotConfiguredError
  end

  it "load the classifier and learns it regarding a balanced training set if set in config" do
    config = test_config
    config.instance_variable_set(:@training_data_options, 'balanced')
    use_configuration(config)

    classifier = Wikipedia::VandalismDetection::Classifier.new

    # 2 vandalism, 2 regular, see resources/corpora/training/annotations.csv
    expect(classifier.dataset.n_rows).to eq 4
  end

  it "load the classifier and learns it regarding the full configured (unbalanced) training set" do
    config = test_config
    config.instance_variable_set(:@training_data_options, 'unbalanced')
    use_configuration(config)

    classifier = Wikipedia::VandalismDetection::Classifier.new
    dataset = classifier.dataset

    vandalism_class_index = Wikipedia::VandalismDetection::Instances::VANDALISM_CLASS_INDEX
    regular_class_index = Wikipedia::VandalismDetection::Instances::REGULAR_CLASS_INDEX

    vandalism_count = dataset.enumerate_instances.reduce(0) do |count, instance|
      count += 1 if (instance.class_value.to_i == vandalism_class_index)
      count
    end

    regular_count = dataset.enumerate_instances.reduce(0) do |count, instance|
      count += 1 if (instance.class_value.to_i == regular_class_index)
      count
    end

    # 2 vandalism, 4 regular, see resources/corpora/training/annotations.csv
    expect(dataset.n_rows).to eq 6
    expect(regular_count).to eq 4
    expect(vandalism_count).to eq 2
  end

  it "loads the classifier and learns it regarding an oversampled training set if set in config" do
    config = test_config
    config.instance_variable_set(:@training_data_options, 'oversampled')
    use_configuration(config)

    classifier = Wikipedia::VandalismDetection::Classifier.new
    dataset = classifier.dataset

    vandalism_class_index = Wikipedia::VandalismDetection::Instances::VANDALISM_CLASS_INDEX
    regular_class_index = Wikipedia::VandalismDetection::Instances::REGULAR_CLASS_INDEX

    vandalism_count = dataset.enumerate_instances.reduce(0) do |count, instance|
      count += 1 if (instance.class_value.to_i == vandalism_class_index)
      count
    end

    regular_count = dataset.enumerate_instances.reduce(0) do |count, instance|
      count += 1 if (instance.class_value.to_i == regular_class_index)
      count
    end

    # 4 vandalism, 4 regular, due to SMOTE oversampling
    expect(dataset.n_rows).to eq 8
    expect(regular_count).to eq 4
    expect(vandalism_count).to eq 4
  end

  it "loads the classifier and learns it regarding a customized oversampled training set if set in config" do
    config = test_config
    config.instance_variable_set(:@training_data_options, 'oversampled -p 200 -u false')
    use_configuration(config)

    dataset = Wikipedia::VandalismDetection::Classifier.new.dataset

    vandalism_class_index = Wikipedia::VandalismDetection::Instances::VANDALISM_CLASS_INDEX
    regular_class_index = Wikipedia::VandalismDetection::Instances::REGULAR_CLASS_INDEX

    vandalism_count = dataset.enumerate_instances.reduce(0) do |count, instance|
      count += 1 if (instance.class_value.to_i == vandalism_class_index)
      count
    end

    regular_count = dataset.enumerate_instances.reduce(0) do |count, instance|
      count += 1 if (instance.class_value.to_i == regular_class_index)
      count
    end

    # 2 + 200 % = 6 vandalism, 4 regular, due to SMOTE oversampling without undersampling
    expect(dataset.n_rows).to eq 10
    expect(regular_count).to eq 4
    expect(vandalism_count).to eq 6
  end

  describe "attribute readers" do

    [:classifier_instance, :evaluator, :dataset].each do |name|
      it "has a readable #{name} attribute" do
        expect { @classifier.send(name) }.not_to raise_error
      end
    end

    it "returns an Evaluator instance from attribute #evaluator" do
      expect(@classifier.evaluator).to be_a Wikipedia::VandalismDetection::Evaluator
    end
  end

  describe "#classifiy" do

    before do
      @edit = build(:edit)
      @features = Wikipedia::VandalismDetection::FeatureCalculator.new.calculate_features_for @edit
    end

    it "raises an error if the input param is no Wikipedia::Edit or feature Array" do
      expect { @classifier.classify("data") }.to raise_error ArgumentError
    end

    it "takes a Wikipedia::Edit as input parameter" do
      expect { @classifier.classify @edit }.not_to raise_error
    end

    it "takes a feature Array as input parameter" do
      expect { @classifier.classify @features }.not_to raise_error
    end

    it "returns the same value for both edit and features as parameter" do
      confidence_from_edit = @classifier.classify @edit
      confidence_from_features = @classifier.classify @features

      expect(confidence_from_edit).to eq confidence_from_features
    end

    it "returns a Numeric value which represents the confidence of vandalism class" do
      confidence = @classifier.classify @features
      expect(confidence).to be_a Numeric
    end

    it "returns an array that holds the confidence at first that is between 0.0 and 1.0" do
      confidence = @classifier.classify @features
      confidence_between_0_and_1 = (confidence <= 1.0) && (confidence >= 0.0)
      expect(confidence_between_0_and_1).to be true
    end

    it "returns -1.0 if features cannot be computed from the edit" do
      Wikipedia::VandalismDetection::FeatureCalculator.any_instance.stub(calculate_features_for: [])
      confidence = @classifier.classify @edit

      expect(confidence).to eq -1.0
    end

    describe "with option ':return_all_params = true'" do

      it "returns a hash" do
        parameters = @classifier.classify @features, return_all_params: true
        expect(parameters).to be_a Hash
      end

      [:confidence, :class_index].each do |key|
        it "returns a hash with key :#{key}" do
          parameters = @classifier.classify @features, return_all_params: true
          expect(parameters.keys).to include key
        end
      end

      it "returns a class_index value of 0 or 1" do
        class_index = @classifier.classify(@features, return_all_params: true)[:class_index]
        is_one_or_zero = class_index == 0 || class_index == 1
        expect(is_one_or_zero).to be true
      end

      it "returns an confidence value that is between 0.0 and 1.0" do
        confidence = (@classifier.classify @features, return_all_params: true)[:confidence]
        confidence_between_0_and_1 = (confidence <= 1.0) && (confidence >= 0.0)
        expect(confidence_between_0_and_1).to be true
      end
    end

    it "raises an argument error if given features are an empty array" do
      expect { @classifier.classify([]) }.to raise_error ArgumentError
    end

    it "does not raise an exception if classifier's classify method returns NaN (i.e. is not implemented)" do
      config = test_config
      config.instance_variable_set(:@classifier_type, 'Meta::OneClassClassifier')
      config.instance_variable_set(:@classifier_options, "-tcl #{Wikipedia::VandalismDetection::Instances::VANDALISM}")

      use_configuration(config)

      # add more test instances because instances number must higher than cross validation fold
      instances = Wikipedia::VandalismDetection::TrainingDataset.instances.to_a2d
      dataset = Wikipedia::VandalismDetection::Instances.empty

      vandalism_index = Wikipedia::VandalismDetection::Instances::VANDALISM_CLASS_INDEX
      regular_index = Wikipedia::VandalismDetection::Instances::REGULAR_CLASS_INDEX

      [vandalism_index, regular_index].each do |index|
        instances.each do |row|
          dataset.add_instance([*row, Wikipedia::VandalismDetection::Instances::CLASSES[index]])
        end
      end

      classifier = Wikipedia::VandalismDetection::Classifier.new(dataset)

      expect { classifier.classify(@features, return_all_params: true) }.not_to raise_exception
    end

    it "does not raise an exception if classifier uses one class classification with 'regular' ast target class" do
      config = test_config
      config.instance_variable_set(:@classifier_type, 'Meta::OneClassClassifier')
      config.instance_variable_set(:@classifier_options, "-tcl #{Wikipedia::VandalismDetection::Instances::REGULAR}")

      use_configuration(config)

      # add more test instances because instances number must higher than cross validation fold
      instances = Wikipedia::VandalismDetection::TrainingDataset.instances.to_a2d
      dataset = Wikipedia::VandalismDetection::Instances.empty

      vandalism_index = Wikipedia::VandalismDetection::Instances::VANDALISM_CLASS_INDEX
      regular_index = Wikipedia::VandalismDetection::Instances::REGULAR_CLASS_INDEX

      [vandalism_index, regular_index].each do |index|
        instances.each do |row|
          dataset.add_instance([*row, Wikipedia::VandalismDetection::Instances::CLASSES[index]])
        end
      end

      classifier = Wikipedia::VandalismDetection::Classifier.new(dataset)

      expect { classifier.classify(@features, return_all_params: true) }.not_to raise_exception
    end
  end

  describe "#cross_validate" do

    it "returns a evaluation object" do
      evaluation = @classifier.cross_validate
      expect(evaluation.class).to be Java::WekaClassifiers::Evaluation
    end

    it "returns an Array of Evaluation objects (when equally distributed option used)" do
      evaluations = @classifier.cross_validate(equally_distributed: true)

      evaluations.each do |evaluation|
        expect(evaluation.class).to be Java::WekaClassifiers::Evaluation
      end
    end
  end
end
require 'spec_helper'

describe Weka::Classifiers::Meta::OneClassClassifier do
  it { is_expected.to be_a Java::WekaClassifiersMeta::OneClassClassifier }

  let(:classifier_type) { 'Meta::OneClassClassifier' }

  before do
    @config = test_config
    classifier_options = '-W weka.classifiers.trees.RandomForest -- -I 100'
    @w_options = "-W weka.classifiers.meta.Bagging -- #{classifier_options}"
    vandalism = Wikipedia::VandalismDetection::Instances::VANDALISM
    options = "-tcl #{vandalism} #{@w_options}"

    @config.instance_variable_set(:@classifier_type, classifier_type)
    @config.instance_variable_set(:@classifier_options, options)
    @config.instance_variable_set(:@cross_validation_fold, 2)

    use_configuration(@config)

    # add more test instances because instances number must be higher than
    # cross validation fold:
    data = Wikipedia::VandalismDetection::TrainingDataset.instances.to_m.to_a
    dataset = Wikipedia::VandalismDetection::Instances.empty

    2.times do
      data.each do |row|
        values = row[0..-2]
        index = rand((0..1))
        class_value = Wikipedia::VandalismDetection::Instances::CLASSES[index]

        dataset.add_instance([*values, class_value])
      end
    end

    allow(Wikipedia::VandalismDetection::TrainingDataset)
      .to receive(:instances)
      .and_return(dataset)
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

  it 'can be used to classify vandalism' do
    classifier = Wikipedia::VandalismDetection::Classifier.new
    features = [1.0, 2.0, 55.0]

    expect(classifier.classify(features)).to be_between(0.0, 1.0)
  end

  it 'can be used to classify vandalism using regulars' do
    regular = Wikipedia::VandalismDetection::Instances::REGULAR
    options = "-tcl #{regular} #{@w_options}"

    @config.instance_variable_set(:@classifier_type, classifier_type)
    @config.instance_variable_set(:@classifier_options, options)

    use_configuration(@config)

    classifier = Wikipedia::VandalismDetection::Classifier.new
    features = [1.0, 2.0, 8.0]

    expect(classifier.classify(features)).to be_between(0.0, 1.0)
  end

  describe '#type' do
    it 'returns the classifier’s type name' do
      expect(Weka::Classifiers::Meta::OneClassClassifier.type)
        .to eq 'Meta::OneClassClassifier'
    end
  end
end

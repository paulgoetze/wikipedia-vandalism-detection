require 'spec_helper'

describe Weka::Classifiers::Meta::RealAdaBoost do
  it { is_expected.to be_a Java::WekaClassifiersMeta::RealAdaBoost }

  before do
    @config = test_config
    classifier_type = 'Meta::RealAdaBoost'
    options = '-W weka.classifiers.trees.RandomForest -- -I 100'

    @config.instance_variable_set(:@classifier_type, classifier_type)
    @config.instance_variable_set(:@classifier_options, options)
    @config.instance_variable_set(:@cross_validation_fold, 2)

    use_configuration(@config)
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
    features = [0.0, 25, 5]

    expect { classifier.classify(features) }.not_to raise_error
  end
end

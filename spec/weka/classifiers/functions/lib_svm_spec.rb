require 'spec_helper'

describe Weka::Classifiers::Functions::LibSVM do

  it { should be_a Java::WekaClassifiersFunctions::LibSVM}

  before do
    @config = test_config
    @config.instance_variable_set :@classifier_type, 'Functions::LibSVM'
    @config.instance_variable_set :@classifier_options, '-S 2 -N 0.001 -M 100.0 -C 1.0 -E 0.001 -P 0.1 -Z'
    @config.instance_variable_set :@cross_validation_fold, '2'

    use_configuration(@config)
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

  it "can be used to classifiy vandalism" do
    expect {
      classifier = Wikipedia::VandalismDetection::Classifier.new
      features = [0.0, 25, 5]
      confidence = classifier.classify(features)
      puts "confidence: #{confidence}"
    }.not_to raise_error
  end
end
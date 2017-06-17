require 'spec_helper'

describe Weka::Classifiers::Trees::BalancedRandomForest do

  it { should be_a Java::WekaClassifiersTrees::BalancedRandomForest }

  before do
    @config = test_config
    options = "-I 100"

    @config.instance_variable_set :@classifier_type, 'Trees::BalancedRandomForest'
    @config.instance_variable_set :@classifier_options, options
    @config.instance_variable_set :@cross_validation_fold, 2

    use_configuration(@config)
  end

  after do
    arff_file = @config.training_output_arff_file
    build_dir = @config.output_base_directory

    if File.exist?(arff_file)
      File.delete(arff_file)
      FileUtils.rm_r(File.dirname arff_file)
    end

    if Dir.exist?(build_dir)
      FileUtils.rm_r(build_dir)
    end
  end

  it "can be used to classify vandalism" do
    expect {
      classifier = Wikipedia::VandalismDetection::Classifier.new
      features = [0.0, 25, 5]
      confidence = classifier.classify features
      puts "vandalism confidence: #{confidence}}"
    }.not_to raise_error
  end
end

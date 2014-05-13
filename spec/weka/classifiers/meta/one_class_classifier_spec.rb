require 'spec_helper'

describe Weka::Classifiers::Meta::OneClassClassifier do

  it { should be_a Java::WekaClassifiersMeta::OneClassClassifier }

  before do
    @config = test_config
    options = "-tcl #{ Wikipedia::VandalismDetection::Instances::VANDALISM }"

    @config.instance_variable_set :@classifier_type, 'Meta::OneClassClassifier'
    @config.instance_variable_set :@classifier_options, options
    @config.instance_variable_set :@cross_validation_fold, 2

    use_configuration(@config)

    # add more test instances because instances number must higher than cross validation fold
    instances = Wikipedia::VandalismDetection::TrainingDataset.instances.to_a2d
    dataset = Wikipedia::VandalismDetection::Instances.empty

    2.times do
      instances.each do |row|
        dataset.add_instance([*row, Wikipedia::VandalismDetection::Instances::CLASSES[rand((0..1))]])
      end
    end

    Wikipedia::VandalismDetection::TrainingDataset.stub(instances: dataset)
    puts Wikipedia::VandalismDetection::TrainingDataset.instances
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

  it "can be used to classify vandalism" do
    expect {
      classifier = Wikipedia::VandalismDetection::Classifier.new
      features = [0.0, 25, 5]
      confidence = classifier.classify features
      puts "vandalism confidence: #{confidence}}"
    }.not_to raise_error
  end
end

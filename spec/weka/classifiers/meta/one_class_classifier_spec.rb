require 'spec_helper'

describe Weka::Classifiers::Meta::OneClassClassifier do

  it { should be_a Java::WekaClassifiersMeta::OneClassClassifier }

  before do
    @config = test_config
    @w_options = "-W weka.classifiers.meta.Bagging -- -W weka.classifiers.trees.RandomForest -- -I 100"
    options = "-tcl #{ Wikipedia::VandalismDetection::Instances::VANDALISM } #{@w_options}"

    @config.instance_variable_set :@classifier_type, 'Meta::OneClassClassifier'
    @config.instance_variable_set :@classifier_options, options
    @config.instance_variable_set :@cross_validation_fold, 2

    use_configuration(@config)

    # add more test instances because instances number must higher than cross validation fold
    instances = Wikipedia::VandalismDetection::TrainingDataset.instances.to_a.map(&:values)
    dataset = Wikipedia::VandalismDetection::Instances.empty

    2.times do
      instances.each do |row|
        values = row[0..-2]
        class_value = Wikipedia::VandalismDetection::Instances::CLASSES[rand((0..1))]
        dataset.add_instance([*values, class_value])
      end
    end

    Wikipedia::VandalismDetection::TrainingDataset.stub(instances: dataset)
    puts Wikipedia::VandalismDetection::TrainingDataset.instances
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
      features = [1.0, 2.0, 55.0]
      confidence = classifier.classify(features)
      puts "vandalism confidence: #{confidence}}"
    }.not_to raise_error
  end

  it "can be used to classify vandalism using regulars" do
    options = "-tcl #{ Wikipedia::VandalismDetection::Instances::REGULAR } #{@w_options}"

    @config.instance_variable_set :@classifier_type, 'Meta::OneClassClassifier'
    @config.instance_variable_set :@classifier_options, options

    use_configuration(@config)

    expect {
      classifier = Wikipedia::VandalismDetection::Classifier.new
      features = [1.0, 2.0, 8.0]
      confidence = classifier.classify(features)
      puts "regular confidence: #{confidence}}"
    }.not_to raise_error
  end

  describe "#type" do
    it "returns the classifier's type name" do
      expect(Weka::Classifiers::Meta::OneClassClassifier.type).to eq 'Meta::OneClassClassifier'
    end
  end
end

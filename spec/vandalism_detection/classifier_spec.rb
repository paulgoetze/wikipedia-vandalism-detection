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

    @classifier.classifier_instance.should be_a class_type
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

  describe "attribute readers" do

    [:classifier_instance, :evaluator, :dataset].each do |name|
      it "has a readable #{name} attribute" do
        expect { @classifier.send(name) }.not_to raise_error
      end
    end

    it "returns an Evaluator instance from attribute #evaluator" do
      @classifier.evaluator.should be_a Wikipedia::VandalismDetection::Evaluator
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
      consensus_from_edit = @classifier.classify @edit
      consensus_from_features = @classifier.classify @features

      consensus_from_edit.should == consensus_from_features
    end

    it "returns a Numeric value which represents the consensus of vandalism class" do
      consensus = @classifier.classify @features
      consensus.should be_a Numeric
    end

    it "returns an array that holds the consensus at first that is between 0.0 and 1.0" do
      consensus = @classifier.classify @features
      consensus_between_0_and_1 = (consensus <= 1.0) && (consensus >= 0.0)
      consensus_between_0_and_1.should be_true
    end

    it "returns -1.0 if features cannot be computed from the edit" do
      Wikipedia::VandalismDetection::FeatureCalculator.any_instance.stub(calculate_features_for: [])
      consensus = @classifier.classify @edit

      consensus.should == -1.0
    end

    it "raises an argument error if given features are an empty array" do
      expect { @classifier.classify([]) }.to raise_error ArgumentError
    end
  end

  describe "#cross_validate" do

    it "returns a evaluation object" do
      evaluation = @classifier.cross_validate
      evaluation.class.should == Java::WekaClassifiers::Evaluation
    end

    it "returns an Array of Evaluation objects (when equally distributed option used)" do
      evaluations = @classifier.cross_validate(equally_distributed: true)

      evaluations.each do |evaluation|
        evaluation.class.should == Java::WekaClassifiers::Evaluation
      end

      #@classifier.cross_validate(equally_distributed: true)[:precision].should be_a Numeric
      #@classifier.cross_validate(equally_distributed: true)[:recall].should be_a Numeric
      #@classifier.cross_validate(equally_distributed: true)[:area_under_prc].should be_a Numeric
    end
  end
end
require 'spec_helper'

describe Wikipedia::VandalismDetection::Evaluator do

  before do
    use_test_configuration
    @config = test_config

    @training_arff_file = @config.training_output_arff_file
    @test_arff_file = @config.test_output_arff_file
    @build_dir = @config.output_base_directory
    @test_classification_file = @config.test_output_classification_file

    puts @config.test_corpus_ground_truth_file
  end

  after do
    # remove training arff file
    if File.exists?(@training_arff_file)
      File.delete(@training_arff_file)
      FileUtils.rm_r(File.dirname @training_arff_file)
    end

    # remove test arff file
    if File.exists?(@test_arff_file)
      File.delete(@test_arff_file)
      FileUtils.rm_r(File.dirname @test_arff_file)
    end

    # remove classification.txt
    if File.exist?(@test_classification_file)
      File.delete(@test_classification_file)
      File.rm_r(File.dirname @test_classification_file)
    end

    # remove output base directory
    if Dir.exists?(@build_dir)
      FileUtils.rm_r(@build_dir)
    end
  end

  describe "#initialize" do

    it "raises an ArgumentError if classifier attr is not of Wikipedia::VandalismDetection::Classfier" do
      expect { Wikipedia::VandalismDetection::Evaluator.new("") }.to raise_error ArgumentError
    end

    it "does not raise an error while appropriate initialization" do
      classifier = Wikipedia::VandalismDetection::Classifier.new
      expect { Wikipedia::VandalismDetection::Evaluator.new(classifier) }.not_to raise_error
    end
  end

  before do
    classifier = Wikipedia::VandalismDetection::Classifier.new
    @evaluator = Wikipedia::VandalismDetection::Evaluator.new(classifier)
  end

  describe "#create_testcorpus_classification_file!" do

    it "creates a classification file in the base output directory" do
      File.exists?(@test_classification_file).should be_false
      @evaluator.create_testcorpus_classification_file!
      File.exists?(@test_classification_file).should be_true
    end

    it "creates a file with an appropriate header" do
      @evaluator.create_testcorpus_classification_file!
      content = File.open(@test_classification_file, 'r')

      features = Core::Parser.parse_ARFF(@test_arff_file).enumerate_attributes.to_a.map { |attr| attr.name.upcase }[0...-2]
      proposed_header = ['OLDREVID', 'NEWREVID', 'C', 'CONF', *features]
      header = content.lines.first.split(' ')

      header.should == proposed_header
    end

    it "creates a file with an appropriate number of lines" do
      @evaluator.create_testcorpus_classification_file!
      content = File.open(@test_classification_file, 'r')

      samples_count = Core::Parser.parse_ARFF(@test_arff_file).n_rows

      lines = content.lines.to_a
      lines.shift # remove header
      lines.count.should == samples_count
    end
  end

  describe "#evaluate_testcorpus_classification" do

    describe "exceptions" do

      it "raises an GroundTruthFileNotConfiguredError unless a ground thruth file is configured" do
        config = test_config
        config.instance_variable_set :@test_corpus_ground_truth_file, nil
        use_configuration(config)

        classifier = Wikipedia::VandalismDetection::Classifier.new
        evaluator = Wikipedia::VandalismDetection::Evaluator.new(classifier)

        expect { evaluator.evaluate_testcorpus_classification }.to raise_error \
          Wikipedia::VandalismDetection::GroundTruthFileNotConfiguredError
      end

      it "raises an GroundTruthFileNotFoundError unless the ground thruth file can be found" do
        config = test_config
        config.instance_variable_set :@test_corpus_ground_truth_file, 'false-file-name.txt'
        use_configuration(config)

        classifier = Wikipedia::VandalismDetection::Classifier.new
        evaluator = Wikipedia::VandalismDetection::Evaluator.new(classifier)

        expect { evaluator.evaluate_testcorpus_classification }.to raise_error \
          Wikipedia::VandalismDetection::GroundTruthFileNotFoundError
      end
    end

    it "returns a performance values Hash" do
      performance_values = @evaluator.evaluate_testcorpus_classification
      performance_values.should be_a Hash
    end

    [ :true_positive_rate,
      :false_positive_rate,
      :precision,
      :recall,
      :area_under_prc,
      :area_under_roc
    ].each do |attr|
      it "returns a performance values Hash with property'#{attr}'" do
        performance_values = @evaluator.evaluate_testcorpus_classification
        performance_values[attr].should_not be_nil
      end
    end

    it "runs the classification file creation if not available yet" do
      File.exists?(@test_classification_file).should be_false
      @evaluator.evaluate_testcorpus_classification
      File.exists?(@test_classification_file).should be_true
    end
  end

  describe "#cross_validate" do

    it "returns an evaluation object" do
      evaluation = @evaluator.cross_validate
      evaluation.class.should == Java::WekaClassifiers::Evaluation
    end

    it "can cross validates the classifier" do
      expect { @evaluator.cross_validate }.not_to raise_error
    end

    it "can cross validates the classifier with equally distributed samples" do
      expect { @evaluator.cross_validate(equally_distributed: true) }.not_to raise_error
    end
  end

  describe "#curve_data" do

    describe "all samples" do

      before do
        @data = @evaluator.curve_data
      end

      it "returns a Hash" do
        @data.should be_a Hash
      end

      it "includes precision curve data" do
        @data[:precision].should be_a Array
      end

      it "includes recall curve data" do
        @data[:recall].should be_a Array
      end

      it "includes area_under_prc data" do
        @data[:area_under_prc].should be_a Numeric
      end

      it "has non-empty :precision Array contents" do
        puts @data[:precision].to_s
        @data[:precision].should_not be_empty
      end

      it "has non-empty :recall Array contents" do
        puts @data[:recall].to_s
        @data[:recall].should_not be_empty
      end
    end

    describe "equally distributed samples" do

      before do
        @data = @evaluator.curve_data(equally_distributed: true)
      end

      it "returns a Hash" do
        @data.should be_a Hash
      end

      it "includes precision curve data" do
        @data[:precision].should be_a Array
      end

      it "includes recall curve data" do
        @data[:recall].should be_a Array
      end

      it "includes area_under_prc data" do
        @data[:area_under_prc].should be_a Numeric
      end

      it "has non-empty :precision Array contents" do
        puts @data[:precision].to_s
        @data[:precision].should_not be_empty
      end

      it "has non-empty :recall Array contents" do
        puts @data[:recall].to_s
        @data[:recall].should_not be_empty
      end
    end
  end
end
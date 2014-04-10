require 'spec_helper'

describe Wikipedia::VandalismDetection::Evaluator do

  before do
    use_test_configuration
  end

  after do
    @config = Wikipedia::VandalismDetection.configuration
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

  describe "#cross_validate" do

    it "returns a evaluation object" do
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
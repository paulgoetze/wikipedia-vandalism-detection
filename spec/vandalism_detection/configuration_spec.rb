require 'spec_helper'
require 'yaml'

describe Wikipedia::VandalismDetection do

  describe "Configuration class" do

    before do
      Wikipedia::VandalismDetection::DefaultConfiguration.any_instance.stub(source: source_dir)
      @configuration = Wikipedia::VandalismDetection::Configuration.new

      use_test_configuration
    end

    [ :data,
      :features,
      :classifier_type,
      :classifier_options,
      :cross_validation_fold
    ].each do |attribute|
      it "responds to ##{attribute}" do
        @configuration.should respond_to attribute
      end
    end

    it "returns a hash for #data (the full config hash) " do
      @configuration.data.should be_a Hash
    end

    it "returns a feature array for #feature" do
      @configuration.features.should be_a Array
    end

    it "returns a numeric for cross-validation-fold" do
      @configuration.cross_validation_fold.should be_a Numeric
    end

    [ :training_corpus_edits_file,
      :training_corpus_annotations_file,
      :training_corpus_revisions_directory,
      :test_corpus_edits_file,
      :test_corpus_revisions_directory,
      :training_output_arff_file,
      :training_output_index_file,
      :test_output_arff_file,
      :test_output_index_file,
      :classifier_type,
      :classifier_options,
      :output_base_directory
    ].each do |attribute|
      it "returns a string when calling ##{attribute}" do
        @configuration.send(attribute).should be_a String
      end
    end
  end

  describe "#configuration" do

    it "can be overridden by a config.yml file" do
      Wikipedia::VandalismDetection::DefaultConfiguration.any_instance.stub(source: source_dir)

      default_config = Wikipedia::VandalismDetection::DefaultConfiguration::DEFAULTS
      custom_config = YAML.load_file(File.expand_path('../../resources/config/config.yml', __FILE__))

      Wikipedia::VandalismDetection.configuration.data.should == default_config.deep_merge(custom_config)
    end

    it "returns a Wikipedia::VandalismDetection::Configuration" do
      Wikipedia::VandalismDetection.configuration.should be_a Wikipedia::VandalismDetection::Configuration
    end

    it "has all features as default configuration" do
      use_default_configuration

      features = [
          "anonymity",
          "biased frequency",
          "biased impact",
          "character sequence",
          "comment length",
          "compressibility",
          "digit ratio",
          "longest word",
          "pronoun frequency",
          "pronoun impact",
          "replacement similarity",
          "size ratio",
          "term frequency",
          "upper case ratio",
          "upper to lower case ratio",
          "vulgarism frequency",
          "vulgarism impact"
      ]

      Wikipedia::VandalismDetection.configuration['features'].should == features
    end

    describe "#configuration#corpora" do

      before do
        use_default_configuration
      end

      it "has a corpora config" do
        Wikipedia::VandalismDetection.configuration['corpora'].should be_a Hash
      end

      [:training, :test].each do |attribute|
        it "has a #{attribute}-corpus config" do
          Wikipedia::VandalismDetection.configuration['corpora'][attribute.to_s].should be_a Hash
        end
      end

      it "has a default nil corpora-base_directory config" do
        Wikipedia::VandalismDetection.configuration['corpora']['base_directory'].should be_nil
      end

      [:base_directory, :revisions_directory, :edits_file, :annotations_file].each do |attribute|
        it "has an default nil '#{attribute}' config for the training-corpus" do
          Wikipedia::VandalismDetection.configuration['corpora']['training'][attribute.to_s].should be_nil
        end
      end

      [:base_directory, :revisions_directory, :edits_file].each do |attribute|
        it "has an default nil '#{attribute}' config for the test-corpus" do
          Wikipedia::VandalismDetection.configuration['corpora']['test'][attribute.to_s].should be_nil
        end
      end
    end

    describe '#configuration#output' do

      before do
        use_default_configuration
      end

      it "has an output-config" do
        Wikipedia::VandalismDetection.configuration['output'].should be_a Hash
      end

      describe "output sub configs" do

        before do
          @output_config = Wikipedia::VandalismDetection.configuration['output']
          @output_config.should be_a Hash
        end

        it "has a default 'base_directory' output-config" do
          @output_config['base_directory'].should_not be_nil
        end

        [:arff_file, :index_file].each do |attribute|
          it "has a default '#{attribute}' config for the training-output" do
            output_training_config = @output_config['training']
            output_training_config.should_not be_nil
            output_training_config[attribute.to_s].should_not be_nil
          end
        end

        [:arff_file, :index_file].each do |attribute|
          it "has a default '#{attribute}' config for the test-output" do
            output_test_config = @output_config['training']
            output_test_config.should_not be_nil
            output_test_config[attribute.to_s].should_not be_nil
          end
        end

      end
    end

    describe "#configuration#classifier" do

      before do
        use_default_configuration
      end

      it "has a classifier config" do
        expect { Wikipedia::VandalismDetection.configuration['classifier'] }.not_to raise_error
      end

      it "return a classifier Hash" do
        Wikipedia::VandalismDetection.configuration['classifier'].should be_a Hash
      end

      [:type, :options].each do |attribute|
        it "has a default nil '#{attribute}' config for classification" do
          Wikipedia::VandalismDetection.configuration['classifier'][attribute.to_s].should be_nil
        end
      end

      it "has a default 10 'cross-validation-fold' config for classifier evaluation" do
        Wikipedia::VandalismDetection.configuration['classifier']['cross-validation-fold'].should == 10
      end
    end
  end

end

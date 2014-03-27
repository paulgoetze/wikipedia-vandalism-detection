require 'spec_helper'
require 'yaml'

describe Wikipedia::VandalismDetection do

  describe "#configuration" do

    it "can be overridden by a config.yml file" do
      Wikipedia::VandalismDetection::Configuration.any_instance.stub(source: source_dir)

      default_config = Wikipedia::VandalismDetection::Configuration::DEFAULTS
      custom_config = YAML.load_file(File.expand_path('../../resources/config/config.yml', __FILE__))

      Wikipedia::VandalismDetection.configuration.should == default_config.deep_merge(custom_config)
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

    describe "#configuration#training_corpus" do

      before do
        use_default_configuration
      end

      it "has a training-corpus config" do
        Wikipedia::VandalismDetection.configuration['training_corpus'].should be_a Hash
      end

      [:revisions_directory, :edits_file, :annotations_file].each do |attribute|
        it "has an default nil '#{attribute}' config for training-corpus" do
          Wikipedia::VandalismDetection.configuration['training_corpus'][attribute.to_s].should be_nil
        end
      end

      [:arff_file, :index_file].each do |attribute|
        it "has an #'#{attribute}' config for training-corpus" do
          Wikipedia::VandalismDetection.configuration['training_corpus'][attribute.to_s].should_not be_nil
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

      it "has a training-corpus of type Wikipedia::VandalismDetection::Configuration::Classifier" do
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
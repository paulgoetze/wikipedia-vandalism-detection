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
      :cross_validation_fold,
      :training_data_options,
      :balanced_training_data?,
      :unbalanced_training_data?,
      :oversampled_training_data?,
      :test_output_classification_file
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

    it "returns a numeric for #cross-validation-fold" do
      @configuration.cross_validation_fold.should be_a Numeric
    end

    describe "#test_output_classification_file" do
      it "returns the classification file path extended by classifier name and training data options" do
        file_path = @configuration.test_output_classification_file

      end
    end

    describe "#use_occ?" do
      it "returns true if used classifier is a one class classifier (occ)" do
        config = test_config
        config.instance_variable_set(:@classifier_type, Weka::Classifiers::Meta::OneClassClassifier.type)
        use_configuration(config)

        Wikipedia::VandalismDetection.configuration.use_occ?.should be_true
      end

      it "returns false if used classifier is not a one class classifier (occ)" do
        use_test_configuration
        Wikipedia::VandalismDetection.configuration.use_occ?.should be_false
      end
    end

    describe "#balanced_training_data?" do

      it "returns true if it is set in config" do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'balanced')
        use_configuration(config)

        Wikipedia::VandalismDetection.configuration.balanced_training_data?.should be_true
      end

      it "returns false if it is not set in config" do
        config = test_config
        config.instance_variable_set(:@training_data_options, nil)
        use_configuration(config)

        Wikipedia::VandalismDetection.configuration.balanced_training_data?.should be_false
      end

      it "returns false if it is set to other value than 'balanced'" do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'other')
        use_configuration(config)

        Wikipedia::VandalismDetection.configuration.balanced_training_data?.should be_false
      end
    end

    describe "#unbalanced_training_data?" do

      it "returns true if it is set in config" do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'unbalanced')
        use_configuration(config)

        Wikipedia::VandalismDetection.configuration.unbalanced_training_data?.should be_true
      end

      it "returns true if it is not set in config" do
        config = test_config
        config.instance_variable_set(:@training_data_options, nil)
        use_configuration(config)

        Wikipedia::VandalismDetection.configuration.unbalanced_training_data?.should be_true
      end

      it "returns true if it is set to other value than 'unbalanced' or 'oversampled'" do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'other value')
        use_configuration(config)

        Wikipedia::VandalismDetection.configuration.unbalanced_training_data?.should be_true
      end

      it "returns false if it is set to other value than 'unbalanced'" do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'balanced')
        use_configuration(config)

        Wikipedia::VandalismDetection.configuration.unbalanced_training_data?.should be_false
      end
    end

    describe "#oversampled_training_data?" do

      it "returns true if it is set in config" do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'oversampled')
        use_configuration(config)

        Wikipedia::VandalismDetection.configuration.oversampled_training_data?.should be_true
      end

      it "returns false if it is not set in config" do
        config = test_config
        config.instance_variable_set(:@training_data_options, nil)
        use_configuration(config)

        Wikipedia::VandalismDetection.configuration.oversampled_training_data?.should be_false
      end

      it "returns false if it is set to other value than 'balanced'" do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'other')
        use_configuration(config)

        Wikipedia::VandalismDetection.configuration.oversampled_training_data?.should be_false
      end
    end

    [ :training_corpus_edits_file,
      :training_corpus_annotations_file,
      :training_corpus_revisions_directory,
      :test_corpus_edits_file,
      :test_corpus_revisions_directory,
      :test_corpus_ground_truth_file,
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
          "anonymity previous",
          "all wordlists frequency",
          "all wordlists impact",
          "bad frequency",
          "bad impact",
          "biased frequency",
          "biased impact",
          "character sequence",
          "character diversity",
          "comment length",
          "comment biased frequency",
          "comment pronoun frequency",
          "comment vulgarism frequency",
          "compressibility",
          "copyedit",
          "digit ratio",
          "edits per user",
          "inserted size",
          "inserted character distribution",
          "inserted external links",
          "inserted internal links",
          "longest word",
          "markup frequency",
          "markup impact",
          "non-alphanumeric ratio",
          "personal life",
          "pronoun frequency",
          "pronoun impact",
          "removed size",
          "removed all wordlists frequency",
          "removed bad frequency",
          "removed biased frequency",
          "removed markup frequency",
          "removed pronoun frequency",
          "removed sex frequency",
          "removed vulgarism frequency",
          "replacement similarity",
          "reverted",
          "revisions character distribution",
          "sex frequency",
          "sex impact",
          "same editor",
          "size ratio",
          "term frequency",
          "time interval",
          "time of day",
          "upper case ratio",
          "upper case words ratio",
          "upper to lower case ratio",
          "user reputation",
          "vulgarism frequency",
          "vulgarism impact",
          "weekday"
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

      it "has a default 'training-data-options' config of unbalanced for classifier training" do
        Wikipedia::VandalismDetection.configuration['classifier']['training-data-options'].should == 'unbalanced'
      end
    end
  end

end

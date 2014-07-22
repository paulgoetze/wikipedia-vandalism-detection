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
      :test_output_classification_file,
      :oversampling_options,
      :training_output_arff_file,
      :test_output_arff_file
    ].each do |attribute|
      it "responds to ##{attribute}" do
        expect(@configuration).to respond_to attribute
      end
    end

    it "returns a hash for #data (the full config hash) " do
      expect(@configuration.data).to be_a Hash
    end

    it "returns a feature array for #feature" do
      expect(@configuration.features).to be_an Array
    end

    it "returns a numeric for #cross-validation-fold" do
      expect(@configuration.cross_validation_fold).to be_a Numeric
    end

    describe "#test_output_classification_file" do
      it "returns the classification file path extended by classifier name and training data options" do
        file_path = @configuration.test_output_classification_file
        classifier_name = @configuration.classifier_type.split('::').last.downcase
        dataset_options = @configuration.training_data_options
        file_name = Wikipedia::VandalismDetection::DefaultConfiguration::DEFAULTS['output']['test']['classification_file']

        path = File.join(@configuration.output_base_directory, classifier_name, dataset_options, file_name)
        expect(file_path).to eq path
      end
    end

    describe "output arff files" do
      describe "#training_output_arff_file" do
        it "returns the arff file path extended by classifier name and training data options" do
          file_path = @configuration.training_output_arff_file
          classifier_name = @configuration.classifier_type.split('::').last.downcase
          dataset_options = @configuration.training_data_options
          file_name = Wikipedia::VandalismDetection::DefaultConfiguration::DEFAULTS['output']['training']['arff_file']

          path = File.join(@configuration.output_base_directory, classifier_name, dataset_options, file_name)
          expect(file_path).to eq path
        end
      end

      describe "#test_output_arff_file" do
        it "returns the arff file path extended by classifier name and training data options" do
          file_path = @configuration.test_output_arff_file
          classifier_name = @configuration.classifier_type.split('::').last.downcase
          dataset_options = @configuration.training_data_options
          file_name = Wikipedia::VandalismDetection::DefaultConfiguration::DEFAULTS['output']['test']['arff_file']

          path = File.join(@configuration.output_base_directory, classifier_name, dataset_options, file_name)
          expect(file_path).to eq path
        end
      end
    end

    describe "#use_occ?" do
      it "returns true if used classifier is a one class classifier (occ)" do
        config = test_config
        config.instance_variable_set(:@classifier_type, Weka::Classifiers::Meta::OneClassClassifier.type)
        use_configuration(config)

        expect(Wikipedia::VandalismDetection.configuration.use_occ?).to be true
      end

      it "returns false if used classifier is not a one class classifier (occ)" do
        use_test_configuration
        expect(Wikipedia::VandalismDetection.configuration.use_occ?).to be false
      end
    end

    describe "#balanced_training_data?" do

      it "returns true if it is set in config" do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'balanced')
        use_configuration(config)

        expect(Wikipedia::VandalismDetection.configuration.balanced_training_data?).to be true
      end

      it "returns false if it is not set in config" do
        config = test_config
        config.instance_variable_set(:@training_data_options, nil)
        use_configuration(config)

        expect(Wikipedia::VandalismDetection.configuration.balanced_training_data?).to be false
      end

      it "returns false if it is set to other value than 'balanced'" do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'other')
        use_configuration(config)

        expect(Wikipedia::VandalismDetection.configuration.balanced_training_data?).to be false
      end
    end

    describe "#unbalanced_training_data?" do

      it "returns true if it is set in config" do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'unbalanced')
        use_configuration(config)

        expect(Wikipedia::VandalismDetection.configuration.unbalanced_training_data?).to be true
      end

      it "returns true if it is not set in config" do
        config = test_config
        config.instance_variable_set(:@training_data_options, nil)
        use_configuration(config)

        expect(Wikipedia::VandalismDetection.configuration.unbalanced_training_data?).to be true
      end

      it "returns true if it is set to other value than 'unbalanced' or 'oversampled'" do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'other value')
        use_configuration(config)

        expect(Wikipedia::VandalismDetection.configuration.unbalanced_training_data?).to be true
      end

      it "returns false if it is set to other value than 'unbalanced'" do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'balanced')
        use_configuration(config)

        expect(Wikipedia::VandalismDetection.configuration.unbalanced_training_data?).to be false
      end
    end

    describe "#oversampled_training_data?" do

      it "returns true if it is set in config" do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'oversampled')
        use_configuration(config)

        expect(Wikipedia::VandalismDetection.configuration.oversampled_training_data?).to be true
      end

      it "returns false if it is not set in config" do
        config = test_config
        config.instance_variable_set(:@training_data_options, nil)
        use_configuration(config)

        expect(Wikipedia::VandalismDetection.configuration.oversampled_training_data?).to be false
      end

      it "returns false if it is set to other value than 'balanced'" do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'other')
        use_configuration(config)

        expect(Wikipedia::VandalismDetection.configuration.oversampled_training_data?).to be false
      end
    end

    describe "#oversampled_options" do
      it "returns a hash" do
        expect(@configuration.oversampling_options).to be_a Hash
      end

      it "returns a hash with the :percent and :undersampling keys" do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'oversampled')
        use_configuration(config)

        hash = { percentage: 0, undersampling: true }
        expect(Wikipedia::VandalismDetection.configuration.oversampling_options.keys).to eq hash.keys
      end

      it "returns an empty hash if training data is not oversampled" do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'other')
        use_configuration(config)

        expect(Wikipedia::VandalismDetection.configuration.oversampling_options).to be {}
      end

      describe "Returning of configured options" do
        before do
          @percentage = 300.0
          @undersampling = 200.0
          @hash = { percentage: @percentage, undersampling: @undersampling }
        end

        it "returns the configured options with downcase params" do
          config = test_config
          options = "oversampled -p #{@percentage} -u true #{@undersampling}"
          config.instance_variable_set(:@training_data_options, options)
          use_configuration(config)

          expect(Wikipedia::VandalismDetection.configuration.oversampling_options).to eq @hash
        end

        it "returns the configured options with upcase params" do
          config = test_config
          options = "oversampled -P #{@percentage} -U true #{@undersampling}"
          config.instance_variable_set(:@training_data_options, options)
          use_configuration(config)

          expect(Wikipedia::VandalismDetection.configuration.oversampling_options).to eq @hash
        end

        it "returns the configured options with full params" do
          config = test_config
          options = "oversampled -Percentage #{@percentage} -Undersampling true #{@undersampling}"
          config.instance_variable_set(:@training_data_options, options)
          use_configuration(config)

          expect(Wikipedia::VandalismDetection.configuration.oversampling_options).to eq @hash
        end
      end

      it "returns a default value for percent if not set" do
        percentage = 100 # default value
        undersampling = 200
        hash = { percentage: percentage, undersampling: undersampling }

        config = test_config
        config.instance_variable_set(:@training_data_options, "oversampled -u true #{undersampling}")
        use_configuration(config)

        expect(Wikipedia::VandalismDetection.configuration.oversampling_options).to eq hash
      end

      it "returns a default true for undersampling if not set" do
        percentage = 200
        undersampling = 100 # default value
        hash = { percentage: percentage, undersampling: undersampling }

        config = test_config
        config.instance_variable_set(:@training_data_options, "oversampled -p #{percentage}")
        use_configuration(config)

        expect(Wikipedia::VandalismDetection.configuration.oversampling_options).to eq hash
      end

      it "returns a percentange value for undersampling if set in -u option" do
        percentage = 200
        undersampling = 0.001
        hash = { percentage: percentage, undersampling: undersampling }

        config = test_config
        config.instance_variable_set(:@training_data_options, "oversampled -p #{percentage} -u true #{undersampling}")
        use_configuration(config)

        expect(Wikipedia::VandalismDetection.configuration.oversampling_options).to eq hash
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
        expect(@configuration.send(attribute)).to be_a String
      end
    end
  end

  describe "#configuration" do

    it "can be overridden by a config.yml file" do
      Wikipedia::VandalismDetection::DefaultConfiguration.any_instance.stub(source: source_dir)

      default_config = Wikipedia::VandalismDetection::DefaultConfiguration::DEFAULTS
      custom_config = YAML.load_file(File.expand_path('../../resources/config/config.yml', __FILE__))

      expect(Wikipedia::VandalismDetection.configuration.data).to eq default_config.deep_merge(custom_config)
    end

    it "returns a Wikipedia::VandalismDetection::Configuration" do
      expect(Wikipedia::VandalismDetection.configuration).to be_a Wikipedia::VandalismDetection::Configuration
    end

    it "has all features as default configuration" do
      use_default_configuration

      features = [
          "anonymity",
          "anonymity previous",
          "all wordlists frequency",
          "all wordlists impact",
          "article size",
          "bad frequency",
          "bad impact",
          "biased frequency",
          "biased impact",
          "blanking",
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
          "emoticons frequency",
          "emoticons impact",
          "inserted size",
          "inserted words",
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
          "removed words",
          "removed all wordlists frequency",
          "removed bad frequency",
          "removed biased frequency",
          "removed character distribution",
          "removed emoticons frequency",
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
          "size increment",
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
          "weekday",
          "words increment"
      ]

      expect(Wikipedia::VandalismDetection.configuration['features']).to eq features
    end

    describe "#configuration#corpora" do

      before do
        use_default_configuration
      end

      it "has a corpora config" do
        expect(Wikipedia::VandalismDetection.configuration['corpora']).to be_a Hash
      end

      [:training, :test].each do |attribute|
        it "has a #{attribute}-corpus config" do
          expect(Wikipedia::VandalismDetection.configuration['corpora'][attribute.to_s]).to be_a Hash
        end
      end

      it "has a default nil corpora-base_directory config" do
        expect(Wikipedia::VandalismDetection.configuration['corpora']['base_directory']).to be nil
      end

      [:base_directory, :revisions_directory, :edits_file, :annotations_file].each do |attribute|
        it "has an default nil '#{attribute}' config for the training-corpus" do
          expect(Wikipedia::VandalismDetection.configuration['corpora']['training'][attribute.to_s]).to be nil
        end
      end

      [:base_directory, :revisions_directory, :edits_file].each do |attribute|
        it "has an default nil '#{attribute}' config for the test-corpus" do
          expect(Wikipedia::VandalismDetection.configuration['corpora']['test'][attribute.to_s]).to be nil
        end
      end
    end

    describe '#configuration#output' do

      before do
        use_default_configuration
      end

      it "has an output-config" do
        expect(Wikipedia::VandalismDetection.configuration['output']).to be_a Hash
      end

      describe "output sub configs" do

        before do
          @output_config = Wikipedia::VandalismDetection.configuration['output']
          expect(@output_config).to be_a Hash
        end

        it "has a default 'base_directory' output-config" do
          expect(@output_config['base_directory']).to_not be nil
        end

        [:arff_file, :index_file].each do |attribute|
          it "has a default '#{attribute}' config for the training-output" do
            output_training_config = @output_config['training']
            expect(output_training_config).to_not be nil
            expect(output_training_config[attribute.to_s]).to_not be nil
          end
        end

        [:arff_file, :index_file].each do |attribute|
          it "has a default '#{attribute}' config for the test-output" do
            output_test_config = @output_config['training']
            expect(output_test_config).to_not be nil
            expect(output_test_config[attribute.to_s]).to_not be nil
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
        expect(Wikipedia::VandalismDetection.configuration['classifier']).to be_a Hash
      end

      [:type, :options].each do |attribute|
        it "has a default nil '#{attribute}' config for classification" do
          expect(Wikipedia::VandalismDetection.configuration['classifier'][attribute.to_s]).to be_nil
        end
      end

      it "has a default 10 'cross-validation-fold' config for classifier evaluation" do
        expect(Wikipedia::VandalismDetection.configuration['classifier']['cross-validation-fold']).to eq 10
      end

      it "has a default 'training-data-options' config of unbalanced for classifier training" do
        expect(Wikipedia::VandalismDetection.configuration['classifier']['training-data-options']).to eq 'unbalanced'
      end
    end
  end

end

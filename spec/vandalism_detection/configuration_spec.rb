require 'spec_helper'
require 'yaml'

describe Wikipedia::VandalismDetection do
  DEFAULTS = Wikipedia::VandalismDetection::DefaultConfiguration::DEFAULTS

  describe 'Configuration class' do
    before do
      allow_any_instance_of(Wikipedia::VandalismDetection::DefaultConfiguration)
        .to receive(:source)
        .and_return(source_dir)

      @config = Wikipedia::VandalismDetection::Configuration.instance

      use_test_configuration
    end

    %i[
      data
      features
      classifier_type
      classifier_options
      cross_validation_fold
      training_data_options
      balanced_training_data?
      unbalanced_training_data?
      oversampled_training_data?
      test_output_classification_file
      oversampling_options
      training_output_arff_file
      test_output_arff_file
      replace_training_data_missing_values?
    ].each do |attribute|
      it "responds to ##{attribute}" do
        expect(@config).to respond_to attribute
      end
    end

    it 'returns a hash for #data (the full config hash)' do
      expect(@config.data).to be_a Hash
    end

    it 'returns a feature array for #feature' do
      expect(@config.features).to be_an Array
    end

    it 'returns a numeric for #cross-validation-fold' do
      expect(@config.cross_validation_fold).to be_a Numeric
    end

    describe '#test_output_classification_file' do
      it 'returns the classification file path extended by classifier name and training data options' do
        file_path = @config.test_output_classification_file
        classifier_name = @config.classifier_type.split('::').last.downcase
        dataset_options = @config.training_data_options
        file_name = DEFAULTS['output']['test']['classification_file']

        path = File.join(
          @config.output_base_directory,
          classifier_name,
          dataset_options,
          file_name
        )

        expect(file_path).to eq path
      end
    end

    describe 'output arff files' do
      describe '#training_output_arff_file' do
        it 'returns the arff file path extended by classifier name and training data options' do
          file_path = @config.training_output_arff_file
          classifier_name = @config.classifier_type.split('::').last.downcase
          dataset_options = @config.training_data_options
          file_name = DEFAULTS['output']['training']['arff_file']

          path = File.join(
            @config.output_base_directory,
            classifier_name,
            dataset_options,
            file_name
          )

          expect(file_path).to eq path
        end
      end

      describe '#test_output_arff_file' do
        it 'returns the arff file path extended by classifier name and training data options' do
          file_path = @config.test_output_arff_file
          classifier_name = @config.classifier_type.split('::').last.downcase
          dataset_options = @config.training_data_options
          file_name = DEFAULTS['output']['test']['arff_file']

          path = File.join(
            @config.output_base_directory,
            classifier_name,
            dataset_options,
            file_name
          )

          expect(file_path).to eq path
        end
      end
    end

    describe '#use_occ?' do
      it 'returns true if used classifier is a one class classifier' do
        config = test_config
        classifier_type = Weka::Classifiers::Meta::OneClassClassifier.type
        config.instance_variable_set(:@classifier_type, classifier_type)
        use_configuration(config)
        use_occ = Wikipedia::VandalismDetection.config.use_occ?

        expect(use_occ).to be true
      end

      it 'returns false if used classifier isn’t a one class classifier' do
        use_test_configuration
        use_occ = Wikipedia::VandalismDetection.config.use_occ?

        expect(use_occ).to be false
      end
    end

    describe '#balanced_training_data?' do
      context 'if it is set in config' do
        it 'returns true' do
          config = test_config
          config.instance_variable_set(:@training_data_options, 'balanced')
          use_configuration(config)
          balanced = Wikipedia::VandalismDetection.config.balanced_training_data?

          expect(balanced).to be true
        end
      end

      context 'if it is not set in config' do
        it 'returns false ' do
          config = test_config
          config.instance_variable_set(:@training_data_options, nil)
          use_configuration(config)
          balanced = Wikipedia::VandalismDetection.config.balanced_training_data?

          expect(balanced).to be false
        end
      end

      context 'if it is set to other value than "balanced"' do
        it 'returns false' do
          config = test_config
          config.instance_variable_set(:@training_data_options, 'other')
          use_configuration(config)
          balanced = Wikipedia::VandalismDetection.config.balanced_training_data?

          expect(balanced).to be false
        end
      end
    end

    describe '#unbalanced_training_data?' do
      context 'if it is set in config' do
        it 'returns true' do
          config = test_config
          config.instance_variable_set(:@training_data_options, 'unbalanced')
          use_configuration(config)
          unbalanced = Wikipedia::VandalismDetection.config.unbalanced_training_data?

          expect(unbalanced).to be true
        end
      end

      context 'if it is not set in config' do
        it 'returns true' do
          config = test_config
          config.instance_variable_set(:@training_data_options, nil)
          use_configuration(config)
          unbalanced = Wikipedia::VandalismDetection.config.unbalanced_training_data?

          expect(unbalanced).to be true
        end
      end

      context 'if set to other value than "unbalanced" or "oversampled"' do
        it 'returns true' do
          config = test_config
          config.instance_variable_set(:@training_data_options, 'other value')
          use_configuration(config)
          unbalanced = Wikipedia::VandalismDetection.config.unbalanced_training_data?

          expect(unbalanced).to be true
        end
      end

      context 'if it is set to other value than "unbalanced"' do
        it 'returns false' do
          config = test_config
          config.instance_variable_set(:@training_data_options, 'balanced')
          use_configuration(config)
          unbalanced = Wikipedia::VandalismDetection.config.unbalanced_training_data?

          expect(unbalanced).to be false
        end
      end
    end

    describe '#oversampled_training_data?' do
      context 'if it is set in config' do
        it 'returns true' do
          config = test_config
          config.instance_variable_set(:@training_data_options, 'oversampled')
          use_configuration(config)
          oversampled = Wikipedia::VandalismDetection.config.oversampled_training_data?

          expect(oversampled).to be true
        end
      end

      context 'if it is not set in config' do
        it 'returns false' do
          config = test_config
          config.instance_variable_set(:@training_data_options, nil)
          use_configuration(config)
          oversampled = Wikipedia::VandalismDetection.config.oversampled_training_data?

          expect(oversampled).to be false
        end
      end

      context 'if it is set to other value than "balanced"' do
        it 'returns false' do
          config = test_config
          config.instance_variable_set(:@training_data_options, 'other')
          use_configuration(config)
          oversampled = Wikipedia::VandalismDetection.config.oversampled_training_data?

          expect(oversampled).to be false
        end
      end
    end

    describe '#oversampled_options' do
      it 'returns a hash' do
        expect(@config.oversampling_options).to be_a Hash
      end

      it 'returns a hash with the :percent and :undersampling keys' do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'oversampled')
        use_configuration(config)

        options = Wikipedia::VandalismDetection.config.oversampling_options
        hash = { percentage: 0, undersampling: true }

        expect(options.keys).to eq hash.keys
      end

      context 'if training data is not oversampled' do
        it 'returns an empty hash' do
          config = test_config
          config.instance_variable_set(:@training_data_options, 'other')
          use_configuration(config)
          options = Wikipedia::VandalismDetection.config.oversampling_options

          expect(options).to eq({})
        end
      end

      describe 'Returning of configured options' do
        let(:percentage) { 300.0 }
        let(:undersampling) { 200.0 }

        let(:sampling_options) do
          {
            percentage: percentage,
            undersampling: undersampling
          }
        end

        it 'returns the configured options with downcase params' do
          config = test_config
          options = "oversampled -p #{percentage} -u true #{undersampling}"
          config.instance_variable_set(:@training_data_options, options)
          use_configuration(config)
          hash = Wikipedia::VandalismDetection.config.oversampling_options

          expect(hash).to eq sampling_options
        end

        it 'returns the configured options with upcase params' do
          config = test_config
          options = "oversampled -P #{percentage} -U true #{undersampling}"
          config.instance_variable_set(:@training_data_options, options)
          use_configuration(config)
          hash = Wikipedia::VandalismDetection.config.oversampling_options

          expect(hash).to eq sampling_options
        end

        it 'returns the configured options with full params' do
          config = test_config
          options = "oversampled -Percentage #{percentage} -Undersampling true #{undersampling}"
          config.instance_variable_set(:@training_data_options, options)
          use_configuration(config)
          hash = Wikipedia::VandalismDetection.config.oversampling_options

          expect(hash).to eq sampling_options
        end
      end

      it 'returns a default value for percent if not set' do
        percentage = 100 # default value
        undersampling = 200
        sampling_options = {
          percentage: percentage,
          undersampling: undersampling
        }

        config = test_config
        options = "oversampled -u true #{undersampling}"
        config.instance_variable_set(:@training_data_options, options)
        use_configuration(config)
        hash = Wikipedia::VandalismDetection.config.oversampling_options

        expect(hash).to eq sampling_options
      end

      it 'returns a default true for undersampling if not set' do
        percentage = 200
        undersampling = 100 # default value
        sampling_options = {
          percentage: percentage,
          undersampling: undersampling
        }

        config = test_config
        options = "oversampled -p #{percentage}"
        config.instance_variable_set(:@training_data_options, options)
        use_configuration(config)
        hash = Wikipedia::VandalismDetection.config.oversampling_options

        expect(hash).to eq sampling_options
      end

      it 'returns a percentange value for undersampling if set in -u option' do
        percentage = 200
        undersampling = 0.001
        sampling_options = {
          percentage: percentage,
          undersampling: undersampling
        }

        config = test_config
        options = "oversampled -p #{percentage} -u true #{undersampling}"
        config.instance_variable_set(:@training_data_options, options)
        use_configuration(config)
        hash = Wikipedia::VandalismDetection.config.oversampling_options

        expect(hash).to eq sampling_options
      end
    end

    describe '#replace_missing_values?' do
      ['no', 'No', 'false', 'nope', '', nil].each do |option|
        it 'returns false if not set' do
          config = test_config
          config.instance_variable_set(:@replace_missing_values, option)
          use_configuration(config)
          replace = Wikipedia::VandalismDetection.config.replace_training_data_missing_values?

          expect(replace).to be false
        end
      end

      %w[yes t T YES True true].each do |option|
        it 'returns true if set' do
          config = test_config
          config.instance_variable_set(:@replace_missing_values, option)
          use_configuration(config)
          replace = Wikipedia::VandalismDetection.config.replace_training_data_missing_values?

          expect(replace).to be true
        end
      end
    end

    %i[
      training_corpus_edits_file
      training_corpus_annotations_file
      training_corpus_revisions_directory
      test_corpus_edits_file
      test_corpus_revisions_directory
      test_corpus_ground_truth_file
      training_output_arff_file
      training_output_index_file
      test_output_arff_file
      test_output_index_file
      classifier_type
      classifier_options
      output_base_directory
    ].each do |attribute|
      it "returns a string when calling ##{attribute}" do
        expect(@config.send(attribute)).to be_a String
      end
    end
  end

  describe '#configuration' do
    it 'can be overridden by a wikipedia-vandalism-detection.yml file' do
      allow_any_instance_of(Wikipedia::VandalismDetection::DefaultConfiguration)
        .to receive(:source)
        .and_return(source_dir)

      default_config = DEFAULTS
      config_file = '../../resources/config/wikipedia-vandalism-detection.yml'
      custom_config = YAML.load_file(File.expand_path(config_file, __FILE__))

      expect(Wikipedia::VandalismDetection.config.data)
        .to eq default_config.deep_merge(custom_config)
    end

    it 'returns a Wikipedia::VandalismDetection::Configuration' do
      expect(Wikipedia::VandalismDetection.config)
        .to be_a Wikipedia::VandalismDetection::Configuration
    end

    it 'has all features as default configuration' do
      use_default_configuration

      features = [
        'anonymity',
        'anonymity previous',
        'all wordlists frequency',
        'all wordlists impact',
        'article size',
        'bad frequency',
        'bad impact',
        'biased frequency',
        'biased impact',
        'blanking',
        'character sequence',
        'character diversity',
        'comment length',
        'comment biased frequency',
        'comment pronoun frequency',
        'comment vulgarism frequency',
        'compressibility',
        'copyedit',
        'digit ratio',
        'edits per user',
        'emoticons frequency',
        'emoticons impact',
        'inserted size',
        'inserted words',
        'inserted character distribution',
        'inserted external links',
        'inserted internal links',
        'longest word',
        'markup frequency',
        'markup impact',
        'non-alphanumeric ratio',
        'personal life',
        'pronoun frequency',
        'pronoun impact',
        'removed size',
        'removed words',
        'removed all wordlists frequency',
        'removed bad frequency',
        'removed biased frequency',
        'removed character distribution',
        'removed emoticons frequency',
        'removed markup frequency',
        'removed pronoun frequency',
        'removed sex frequency',
        'removed vulgarism frequency',
        'replacement similarity',
        'reverted',
        'revisions character distribution',
        'sex frequency',
        'sex impact',
        'same editor',
        'size increment',
        'size ratio',
        'term frequency',
        'time interval',
        'time of day',
        'upper case ratio',
        'upper case words ratio',
        'upper to lower case ratio',
        'vulgarism frequency',
        'vulgarism impact',
        'weekday',
        'words increment'
      ]

      configured_features = Wikipedia::VandalismDetection.config['features']

      expect(configured_features).to eq features
    end

    describe '#configuration#corpora' do
      before do
        use_default_configuration
        @corpora = Wikipedia::VandalismDetection.config['corpora']
      end

      it 'has a corpora config' do
        expect(@corpora).to be_a Hash
      end

      %i[training test].each do |attribute|
        it "has a #{attribute}-corpus config" do
          expect(@corpora[attribute.to_s]).to be_a Hash
        end
      end

      it 'has a default nil corpora-base_directory config' do
        expect(@corpora['base_directory']).to be_nil
      end

      %i[
        base_directory
        revisions_directory
        edits_file
        annotations_file
      ].each do |attribute|
        it "has an default nil '#{attribute}' config for the training-corpus" do
          expect(@corpora['training'][attribute.to_s]).to be_nil
        end
      end

      %i[
        base_directory
        revisions_directory
        edits_file
      ].each do |attribute|
        it "has an default nil '#{attribute}' config for the test-corpus" do
          expect(@corpora['test'][attribute.to_s]).to be_nil
        end
      end
    end

    describe '#configuration#output' do
      before do
        use_default_configuration
        @output_config = Wikipedia::VandalismDetection.config['output']
      end

      it 'has an output-config' do
        expect(@output_config).to be_a Hash
      end

      describe 'output sub configs' do
        it 'has a default "base_directory" output-config' do
          expect(@output_config['base_directory']).to_not be_nil
        end

        %i[arff_file index_file].each do |attribute|
          it "has a default '#{attribute}' config for the training-output" do
            output_training_config = @output_config['training']
            expect(output_training_config).to_not be_nil
            expect(output_training_config[attribute.to_s]).to_not be_nil
          end
        end

        %i[arff_file index_file].each do |attribute|
          it "has a default '#{attribute}' config for the test-output" do
            output_test_config = @output_config['training']
            expect(output_test_config).to_not be nil
            expect(output_test_config[attribute.to_s]).to_not be nil
          end
        end
      end
    end

    describe '#configuration#classifier' do
      before do
        use_default_configuration
        @classifier = Wikipedia::VandalismDetection.config['classifier']
      end

      it 'return a classifier Hash' do
        expect(@classifier).to be_a Hash
      end

      %i[type options].each do |attribute|
        it "has a default nil '#{attribute}' config for classification" do
          expect(@classifier[attribute.to_s]).to be_nil
        end
      end

      it 'has a default 10-fold CV config for evaluation' do
        expect(@classifier['cross-validation-fold']).to eq 10
      end

      it 'has has unbalances training data by default for training' do
        expect(@classifier['training-data-options']).to eq 'unbalanced'
      end
    end
  end
end

require 'spec_helper'
require 'fileutils'

describe Wikipedia::VandalismDetection::TrainingDataset do
  before do
    use_test_configuration
    @config = test_config

    @arff_file = @config.training_output_arff_file
    @index_file = @config.training_output_index_file
    @annotations_file = @config.training_corpus_annotations_file

    @arff_files_dir = File.join(@config.output_base_directory, 'training')
  end

  after do
    if File.exist?(@arff_file)
      File.delete(@arff_file)
      directory = File.dirname(@arff_file)
      FileUtils.rm_r(directory)
    end

    File.delete(@index_file) if File.exist?(@index_file)

    # remove feature arff files
    @config.features.each do |name|
      file = File.join(@arff_files_dir, "#{name.tr(' ', '_')}.arff")

      next unless File.exist?(file)

      File.delete(file)
      directory = File.dirname(file)
      FileUtils.rm_r(directory)
    end
  end

  describe '#build' do
    it 'returns a weka instances' do
      dataset = TrainingDataset.build
      expect(dataset).to be_a Java::WekaCore::Instances
    end

    describe 'exceptions' do
      it 'raises error unless edits file is configured' do
        config = test_config
        config.instance_variable_set(:@training_corpus_edits_file, nil)
        use_configuration(config)

        expect { TrainingDataset.build }.to raise_error \
          Wikipedia::VandalismDetection::EditsFileNotConfiguredError
      end

      it 'raises error unless annotations file is configured' do
        config = test_config
        config.instance_variable_set(:@training_corpus_annotations_file, nil)
        use_configuration(config)

        expect { TrainingDataset.build }.to raise_error \
          Wikipedia::VandalismDetection::AnnotationsFileNotConfiguredError
      end
    end

    Wikipedia::VandalismDetection::DefaultConfiguration::DEFAULTS['features'].each do |name|
      it "creates an arff file for the feature '#{name}'" do
        config = test_config
        config.instance_variable_set(:@features, [name])
        use_configuration(config)

        file = File.join(@arff_files_dir, "#{name.tr(' ', '_')}.arff")

        expect(File.exist?(file)).to be false
        TrainingDataset.build
        expect(File.exist?(file)).to be true
      end
    end

    it 'creates only feature files that are not available yet' do
      config = test_config
      config.instance_variable_set(:@features, ['anonymity', 'comment length'])
      use_configuration(config)

      anonymity_file = File.join(config.output_base_directory, 'test', 'anonymity.arff')

      # create file manually, so it is existent when building the dataset
      data = [1, 2, 3]
      anonymity = Instances.empty_for_test_feature('anonymity')
      6.times { anonymity.add_instance(data) }
      anonymity.to_arff(anonymity_file)

      TrainingDataset.build

      # anonymity should not be overwritten
      values = Weka::Core::Instances.from_arff(anonymity_file).first.values
      expect(values).to eq data
    end

    describe 'internal algorithm' do
      let(:features_count) { @config.features.count }

      it 'builds the right number of data lines' do
        dataset = TrainingDataset.build
        annotations_count = File.open(@annotations_file, 'r').lines.count - 1
        additional_header_lines = 5

        total_lines = additional_header_lines + annotations_count + features_count

        expect(dataset.to_s.lines.count).to eq total_lines
      end

      it 'builds the right number of data columns' do
        dataset = TrainingDataset.build
        expect(dataset.attributes_count).to eq features_count + 1
      end
    end

    describe 'replacing missing values' do
      it 'replaces missing values if configured' do
        config = test_config
        config.instance_variable_set(:@replace_missing_values, 'true')
        use_configuration(config)

        dataset = TrainingDataset.build

        filter = /weka\.filters\.unsupervised\.attribute\.ReplaceMissingValues/
        expect(dataset.to_s).to match filter
      end

      it 'does not replace missing values if not configured' do
        config = test_config
        config.instance_variable_set(:@replace_missing_values, 'Nope')
        use_configuration(config)

        dataset = TrainingDataset.build

        filter = /weka\.filters\.unsupervised\.attribute\.ReplaceMissingValues/
        expect(dataset.to_s).not_to match filter
      end
    end
  end

  describe '#instances' do
    it 'is an alias method for #build' do
      build = TrainingDataset.method(:build)
      instances = TrainingDataset.method(:instances)

      expect(build).to eq instances
    end
  end

  describe '#balanced_instances' do
    before do
      config = test_config
      config.instance_variable_set(:@training_data_options, 'balanced')
      use_configuration(config)

      @dataset = TrainingDataset.balanced_instances
    end

    it 'returns a weka dataset' do
      expect(@dataset).to be_a Java::WekaCore::Instances
    end

    it 'returns a dataset of rigth size built from the configured corpus' do
      # 2 vandalism, 2 regular, see resources/corpora/training/annotations.csv
      expect(@dataset.size).to eq 4
    end

    %i[VANDALISM REGULAR].each do |class_const|
      it "has the right number of '#{class_const.downcase}' samples in its instances" do
        class_count = @dataset.enumerate_instances.reduce(0) do |count, instance|
          label = Instances::CLASSES[instance.class_value.to_i]
          value = Instances.const_get(class_const)

          label == value ? count + 1 : count
        end

        expect(class_count).to eq 2
      end
    end
  end

  describe '#oversampled_instances' do
    describe 'with default options' do
      before do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'oversampled')
        use_configuration(config)

        # default -P 100 -U true
        @dataset = TrainingDataset.oversampled_instances
      end

      it 'returns a weka dataset' do
        expect(@dataset).to be_a Java::WekaCore::Instances
      end

      it 'returns a dataset of size 8 built from the configured corpus' do
        # 4 vandalism, 4 regular, see resources/corpora/training/annotations.csv
        expect(@dataset.size).to eq 8
      end

      %i[VANDALISM REGULAR].each do |class_const|
        it "has the right number of '#{class_const.downcase}' samples in its instances" do
          class_count = @dataset.enumerate_instances.reduce(0) do |count, instance|
            label = Instances::CLASSES[instance.class_value.to_i]
            value = Instances.const_get(class_const)

            label == value ? count + 1 : count
          end

          expect(class_count).to eq 4
        end
      end

      it 'returns the right-sized SMOTEd dataset from the configured corpus' do
        # 4 vandalism, 4 regular, see resources/corpora/training/annotations.csv
        dataset = TrainingDataset.oversampled_instances(percentage: 200)
        expect(dataset.size).to eq 8
      end
    end

    describe 'with custom options' do
      before do
        config = test_config
        options = 'oversampled -p 300 -u false'
        config.instance_variable_set(:@training_data_options, options)
        use_configuration(config)

        @dataset = TrainingDataset.oversampled_instances
      end

      it 'returns a weka dataset' do
        expect(@dataset).to be_a Java::WekaCore::Instances
      end

      it 'returns the right dataset size built from the configured corpus' do
        # 2 + 300 % = 8 vandalism, 4 regular,
        # see resources/corpora/training/annotations.csv
        expect(@dataset.size).to eq 12
      end
    end
  end

  describe '#create_corpus_index_file!' do
    it 'responds to #create_corpus_file_index!' do
      expect(TrainingDataset).to respond_to :create_corpus_file_index!
    end

    describe 'exceptions' do
      it 'raises an error if no revisions directory is configured' do
        config = test_config
        config.instance_variable_set(:@training_corpus_revisions_directory, nil)
        use_configuration(config)

        expect { TrainingDataset.create_corpus_file_index! }.to raise_error \
          Wikipedia::VandalismDetection::RevisionsDirectoryNotConfiguredError
      end
    end

    it 'creates a corpus_index.yml file in the build directory' do
      expect(File.exist?(@index_file)).to be false
      TrainingDataset.create_corpus_file_index!
      expect(File.exist?(@index_file)).to be true
    end
  end
end

require 'spec_helper'
require 'fileutils'
require 'weka'

describe Wikipedia::VandalismDetection::TestDataset do
  subject { Wikipedia::VandalismDetection::TestDataset }

  before do
    use_test_configuration
    @config = test_config

    @arff_file  = @config.test_output_arff_file
    @index_file = @config.test_output_index_file
    @features   = @config.features

    @arff_files_dir = File.join(@config.output_base_directory, 'test')
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
      directory = File.dirname file
      FileUtils.rm_r(directory)
    end
  end

  describe '#build' do
    describe 'exceptions' do
      it 'raises an error if no edits file is configured' do
        config = test_config
        config.instance_variable_set(:@test_corpus_edits_file, nil)
        use_configuration(config)

        expect { subject.build }.to raise_error \
          Wikipedia::VandalismDetection::EditsFileNotConfiguredError
      end
    end

    it 'returns a weka instances' do
      expect(subject.build).to be_a Java::WekaCore::Instances
    end

    Wikipedia::VandalismDetection::DefaultConfiguration::DEFAULTS['features'].each do |name|
      it "creates an arff file for the feature '#{name}'" do
        config = test_config
        config.instance_variable_set(:@features, [name])
        use_configuration(config)

        file = File.join(@arff_files_dir, "#{name.tr(' ', '_')}.arff")

        expect(File.exist?(file)).to be false
        subject.build
        expect(File.exist?(file)).to be true
      end
    end

    it 'creates only feature files that are not available yet' do
      config = test_config
      config.instance_variable_set(:@features, ['anonymity', 'comment length'])
      use_configuration(config)

      anonymity_file = File.join(config.output_base_directory, 'test', 'anonymity.arff')

      # create file manually, so it is existent when building dataset
      data = [1, 2, 3]
      anonymity = Wikipedia::VandalismDetection::Instances.empty_for_test_feature('anonymity')
      6.times { anonymity.add_instance(data) }
      anonymity.to_arff(anonymity_file)

      Wikipedia::VandalismDetection::TestDataset.build

      # anonymity should not be overwritten
      values = Weka::Core::Instances.from_arff(anonymity_file).first.values
      expect(values).to eq data
    end

    describe 'internal algorithm' do
      it 'builds the right number of data lines' do
        edits_count = File.open(@config.training_corpus_edits_file, 'r').lines.count - 1
        additional_header_lines = 4 # without class
        revision_id_lines       = 2 # old and new revision id attributes
        class_line              = 1

        lines_count = [
          additional_header_lines,
          edits_count,
          @features.count,
          revision_id_lines,
          class_line
        ].inject(:+)

        dataset = subject.build

        expect(dataset.to_s.lines.count).to eq lines_count
      end

      it 'builds the right number of data columns' do
        old_and_new_edit_attr_count = 2
        class_value      = 1
        dataset          = subject.build

        attributes_count = [
          @features.count,
          class_value,
          old_and_new_edit_attr_count
        ].inject(:+)

        expect(dataset.attributes_count).to eq attributes_count
      end

      it 'builds a class attribute' do
        dataset = subject.build
        expect(dataset.attributes.last.name).to eq 'class'
      end
    end
  end

  describe '#instances' do
    it 'is an alias method for #build' do
      build     = subject.method(:build)
      instances = subject.method(:instances)

      expect(build).to eq instances
    end
  end

  describe '#create_corpus_index_file!' do
    it 'responds to #create_corpus_file_index!' do
      expect(subject).to respond_to :create_corpus_file_index!
    end

    describe 'exceptions' do
      it 'raises an error unless revisions directory is configured' do
        config = test_config
        config.instance_variable_set(:@test_corpus_revisions_directory, nil)
        use_configuration(config)

        expect { subject.create_corpus_file_index! }.to raise_error \
          Wikipedia::VandalismDetection::RevisionsDirectoryNotConfiguredError
      end
    end

    it 'creates a corpus_index.yml file in the build directory' do
      expect(File.exist?(@index_file)).to be false
      subject.create_corpus_file_index!
      expect(File.exist?(@index_file)).to be true
    end
  end

  describe '#build!' do
    it { is_expected.to respond_to :build! }

    it 'creates an .arff file in the configured irectory' do
      expect(File.exist?(@arff_file)).to be false
      subject.build!
      expect(File.exist?(@arff_file)).to be true
    end

    it 'overwrites existing test arff file' do
      use_test_configuration

      # test config uses 3 features + 2 edit id columns + 1 class value = 6
      subject.build!
      first_parsed_dataset = Weka::Core::Instances.from_arff(@arff_file)
      expect(first_parsed_dataset.attributes_count).to eq 6

      config = test_config
      config.instance_variable_set(:@features, ['anonymity'])
      use_configuration(config)

      # uses only 1 feature + 2 edit id columns + 1 class vlaue = 4
      subject.build!
      second_parsed_dataset = Weka::Core::Instances.from_arff(@arff_file)

      expect(second_parsed_dataset.attributes_count).to eq 4
    end
  end

  describe '#edit' do
    it 'raises an error unless edits file is configured' do
      config = test_config
      config.instance_variable_set(:@test_corpus_edits_file, nil)
      use_configuration(config)

      expect { subject.edit('1', '2') }.to raise_error \
        Wikipedia::VandalismDetection::EditsFileNotConfiguredError
    end

    it 'returns nil if Edit could not be found' do
      edit = subject.edit('1', '2')
      expect(edit).to be_nil
    end

    it 'returns an Edit' do
      edit = subject.edit('307084144', '326873205')
      expect(edit).to be_an Edit
    end

    it 'returns an edit whose parent page title is not nil' do
      edit = subject.edit('307084144', '326873205')
      expect(edit.page.title).to_not be_nil
    end

    it 'returns an edit whose parent page id is not nil' do
      edit = subject.edit('307084144', '326873205')
      expect(edit.page.id).to_not be_nil
    end

    it 'returns nil for a not annotated edit with given revision ids' do
      edit = subject.edit('328774088', '328774188')
      expect(edit).to be_nil
    end
  end
end

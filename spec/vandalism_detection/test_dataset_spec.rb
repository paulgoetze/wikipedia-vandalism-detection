require 'spec_helper'
require 'fileutils'
require 'ruby-band'

describe Wikipedia::VandalismDetection::TestDataset do

  before do
    use_test_configuration
    @config = test_config

    @arff_file = @config.test_output_arff_file
    @index_file = @config.test_output_index_file
    @features = @config.features

    @arff_files_dir = File.join(@config.output_base_directory, 'test')
  end

  after do
    if File.exists?(@arff_file)
      File.delete(@arff_file)
      FileUtils.rm_r(File.dirname @arff_file)
    end

    File.delete(@index_file) if File.exists?(@index_file)

    # remove feature arff files
    @config.features.each do |name|
      file = File.join(@arff_files_dir, name.gsub(' ', '_') + '.arff')

      if File.exists?(file)
        File.delete(file)
        FileUtils.rm_r(File.dirname file)
      end
    end
  end

  describe "#build" do
    describe "exceptions" do
      it "raises an EditsFileNotConfiguredError if no edits file is configured" do
        config = test_config
        config.instance_variable_set :@test_corpus_edits_file, nil
        use_configuration(config)

        expect { Wikipedia::VandalismDetection::TestDataset.build }.to raise_error \
          Wikipedia::VandalismDetection::EditsFileNotConfiguredError
      end
    end

    it "returns a weka instances" do
      dataset = Wikipedia::VandalismDetection::TestDataset.build
      expect(dataset.class).to be Java::WekaCore::Instances
    end

    Wikipedia::VandalismDetection::DefaultConfiguration::DEFAULTS['features'].each do |name|
      it "creates an arff file for the feature '#{name}'" do
        config = test_config
        config.instance_variable_set :@features, [name]
        use_configuration(config)

        file = File.join(@arff_files_dir, name.gsub(' ', '_') + '.arff')

        expect(File.exist?(file)).to be false
        Wikipedia::VandalismDetection::TestDataset.build
        expect(File.exist?(file)).to be true
      end
    end

    it "creates only feature files that are not available yet" do
      config = test_config
      config.instance_variable_set :@features, ['anonymity', 'comment length']
      use_configuration(config)

      anonymity_file = File.join(config.output_base_directory, 'test', 'anonymity.arff')

      # create file manually, so it is existent when building dataset
      data = [10000, 123456, 234567]
      anonymity = Wikipedia::VandalismDetection::Instances.empty_for_test_feature('anonymity')
      6.times { anonymity.add_instance(data) }
      anonymity.to_ARFF(anonymity_file)

      Wikipedia::VandalismDetection::TestDataset.build

      # anonymity should not be overwritten
      expect(Core::Parser.parse_ARFF(anonymity_file).to_a2d.first).to eq data
    end

    describe "internal algorithm" do
      it "builds the right number of data lines" do
        edits_count = File.open(@config.training_corpus_edits_file, 'r').lines.count - 1
        additional_header_lines = 4 # without class
        revision_id_lines = 2 # old and new revision id attributes
        class_line = 1

        lines_count = additional_header_lines + edits_count + @features.count + revision_id_lines + class_line
        dataset = Wikipedia::VandalismDetection::TestDataset.build

        expect(dataset.to_s.lines.count).to eq lines_count
      end

      it "builds the right number of data columns" do
        old_and_new_edit_attr_count = 2
        class_value = 1
        dataset = Wikipedia::VandalismDetection::TestDataset.build

        expect(dataset.n_col).to eq @features.count + class_value + old_and_new_edit_attr_count
      end

      it "builds a class attribute" do
        dataset = Wikipedia::VandalismDetection::TestDataset.build
        expect(dataset.enumerate_attributes.to_a[-1].name).to eq 'class'
      end
    end

    it "normalizes the numeric features if LibSVM is used as classifier" do
      config = test_config
      config.instance_variable_set :@classifier_type, 'Functions::LibSVM'
      use_configuration(config)

      dataset = Wikipedia::VandalismDetection::TestDataset.build
      puts dataset

      dataset.to_a2d.each do |instance|
        puts instance.to_s
        numerics = instance[0...-3] # feature values
        edit_ids = instance[-3..-2] # revision ids

        numerics.each { |value| expect(value).to be_between(0.0, 1.0) }
        edit_ids.each { |value| expect(value).to be > 1 }
      end
    end
  end

  describe "#instances" do
    it "is an alias method for #build" do
      build = Wikipedia::VandalismDetection::TestDataset.build
      instances = Wikipedia::VandalismDetection::TestDataset.instances

      expect(build.to_s).to eq instances.to_s
    end
  end

  describe "#create_corpus_index_file!" do
    it "responds to #create_corpus_file_index!" do
      expect(Wikipedia::VandalismDetection::TestDataset).to respond_to :create_corpus_file_index!
    end

    describe "exceptions" do
      it "raises an RevisionsDirectoryNotConfiguredError if no revisions directory is configured" do
        config = test_config
        config.instance_variable_set :@test_corpus_revisions_directory, nil
        use_configuration(config)

        expect { Wikipedia::VandalismDetection::TestDataset.create_corpus_file_index! }.to raise_error \
          Wikipedia::VandalismDetection::RevisionsDirectoryNotConfiguredError
      end
    end

    it "creates a corpus_index.yml file in the build directory" do
      expect(File.exist?(@index_file)).to be false
      Wikipedia::VandalismDetection::TestDataset.create_corpus_file_index!
      expect(File.exist?(@index_file)).to be true
    end
  end

  describe "#build!" do
    it "should respond to #build!" do
      expect(Wikipedia::VandalismDetection::TestDataset).to respond_to :build!
    end

    it "creates an .arff file in the directory defined in config.yml" do
      expect(File.exist?(@arff_file)).to be false
      Wikipedia::VandalismDetection::TestDataset.build!
      expect(File.exist?(@arff_file)).to be true
    end

    it "overwrites existing test arff file" do
      use_test_configuration

      # test config uses 3 features + 2 edit id columns + 1 class value = 6
      Wikipedia::VandalismDetection::TestDataset.build!
      first_parsed_dataset = Core::Parser.parse_ARFF(@arff_file)
      expect(first_parsed_dataset.n_col).to eq 6

      config = test_config
      config.instance_variable_set(:@features, ['anonymity'])
      use_configuration(config)

      # uses only 1 feature + 2 edit id columns + 1 class vlaue = 4
      Wikipedia::VandalismDetection::TestDataset.build!
      second_parsed_dataset = Core::Parser.parse_ARFF(@arff_file)

      expect(second_parsed_dataset.n_col).to eq 4
    end
  end

  describe "#edit" do
    it "raises an EditsFileNotConfiguredError if no edits file is configured" do
      config = test_config
      config.instance_variable_set :@test_corpus_edits_file, nil
      use_configuration(config)

      expect { Wikipedia::VandalismDetection::TestDataset.edit('1', '2') }.to raise_error \
          Wikipedia::VandalismDetection::EditsFileNotConfiguredError
    end

    it "returns nil if Edit could not be found" do
      edit = Wikipedia::VandalismDetection::TestDataset.edit('1', '2')
      expect(edit).to be_nil
    end

    it "returns an Edit" do
      edit = Wikipedia::VandalismDetection::TestDataset.edit('307084144', '326873205')
      expect(edit).to be_a Wikipedia::VandalismDetection::Edit
    end

    it "returns an edit whose parent page title is not nil" do
      edit = Wikipedia::VandalismDetection::TestDataset.edit('307084144', '326873205')
      expect(edit.page.title).to_not be_nil
    end

    it "returns an edit whose parent page id is not nil" do
      edit = Wikipedia::VandalismDetection::TestDataset.edit('307084144', '326873205')
      expect(edit.page.id).to_not be_nil
    end

    it "returns nil for a not annotated edit with given revision ids" do
      edit = Wikipedia::VandalismDetection::TestDataset.edit('328774088', '328774188')
      expect(edit).to be_nil
    end
  end
end
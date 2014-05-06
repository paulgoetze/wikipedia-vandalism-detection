require 'spec_helper'
require 'fileutils'
require 'ruby-band'

describe Wikipedia::VandalismDetection::TestDataset do

  before do
    use_test_configuration
    @config = test_config

    @arff_file = @config.test_output_arff_file
    @index_file = @config.test_output_index_file

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

  describe "#instances" do

    it "returns a weka instances" do
      dataset = Wikipedia::VandalismDetection::TestDataset.instances
      dataset.class.should == Java::WekaCore::Instances
    end

    it "returns a instances built from the configured corpus" do
      dataset = Wikipedia::VandalismDetection::TestDataset.instances
      parsed_dataset = Core::Parser.parse_ARFF(@arff_file)

      # remove those with -1 values
      filtered_dataset = parsed_dataset.to_a2d.delete_if { |instance| instance.include?(-1) }

      dataset.to_a2d.should == filtered_dataset
    end

    it "overwrites existing test arff file" do
      use_test_configuration

      # test config uses 3 features + 2 edit id columns = 5
      Wikipedia::VandalismDetection::TestDataset.instances
      first_parsed_dataset = Core::Parser.parse_ARFF(@arff_file)
      first_parsed_dataset.n_col.should == 5

      config = test_config
      config.instance_variable_set(:@features, ['anonymity'])
      use_configuration(config)

      # uses only 1 feature + 2 edit id columns = 3
      Wikipedia::VandalismDetection::TestDataset.instances
      second_parsed_dataset = Core::Parser.parse_ARFF(@arff_file)
      second_parsed_dataset.n_col.should == 3
    end
  end

  describe "#create_corpus_index_file!" do

    it "responds to #create_corpus_file_index!" do
      Wikipedia::VandalismDetection::TestDataset.should respond_to(:create_corpus_file_index!)
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
      File.exist?(@index_file).should be_false
      Wikipedia::VandalismDetection::TestDataset.create_corpus_file_index!
      File.exist?(@index_file).should be_true
    end
  end

  describe "#build!" do

    it "should respond to #build!" do
      Wikipedia::VandalismDetection::TestDataset.should respond_to(:build!)
    end

    describe "exceptions" do
      it "raises an EditsFileNotConfiguredError if no edits file is configured" do
        config = test_config
        config.instance_variable_set :@test_corpus_edits_file, nil
        use_configuration(config)

        expect { Wikipedia::VandalismDetection::TestDataset.build! }.to raise_error \
          Wikipedia::VandalismDetection::EditsFileNotConfiguredError
      end
    end

    it "creates an .arff file in the directory defined in config.yml" do
      File.exist?(@arff_file).should be_false
      Wikipedia::VandalismDetection::TestDataset.build!
      File.exist?(@arff_file).should be_true
    end

    Wikipedia::VandalismDetection::DefaultConfiguration::DEFAULTS['features'].each do |name|
      it "creates an arff file for the feature '#{name}'" do
        config = test_config
        config.instance_variable_set :@features, [name]
        use_configuration(config)

        file = File.join(@arff_files_dir, name.gsub(' ', '_') + '.arff')

        File.exist?(file).should be_false
        Wikipedia::VandalismDetection::TestDataset.build!
        File.exist?(file).should be_true
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

      Wikipedia::VandalismDetection::TestDataset.build!

      # anonymity should not be overwritten
      Core::Parser.parse_ARFF(anonymity_file).to_a2d.first.should == data
    end

    describe "internal algorithm" do
      before do
        @features_count = @config.features.count
      end

      it "has builds the right number of data lines" do
        Wikipedia::VandalismDetection::TestDataset.build!

        edits_count = File.open(@config.training_corpus_edits_file, 'r').lines.count - 1
        additional_header_lines = 4 # without class
        revision_id_lines = 2 # old and new revision id attributes

        lines_count = additional_header_lines + edits_count + @features_count + revision_id_lines
        File.open(@arff_file, 'r').lines.count.should == lines_count
      end

      it "builds the right number of data columns" do
        Wikipedia::VandalismDetection::TestDataset.build!
        dataset = Core::Parser.parse_ARFF @arff_file

        old_and_new_edit_attr_count = 2
        dataset.n_col.should == @features_count + old_and_new_edit_attr_count
      end
    end
  end

  describe "#add_feature_to_arff!" do

    before do
      @feature_name = "upper to lower case ratio"
    end

    describe "exceptions" do

      xit "raises an ArffFileNotFound if no arff file has been created, yet" do
        use_test_configuration

        expect { Wikipedia::VandalismDetection::TestDataset.add_feature_to_arff!(@feature_name) }.to raise_error \
            Wikipedia::VandalismDetection::ArffFileNotFoundError
      end

      xit "raises an EditsFileNotConfiguredError if no edits file is configured" do
        config = test_config
        config.instance_variable_set :@training_corpus_edits_file, nil
        use_configuration(config)

        expect { Wikipedia::VandalismDetection::TestDataset.add_feature_to_arff!(@feature_name) }.to raise_error \
            Wikipedia::VandalismDetection::EditsFileNotConfiguredError
      end

      xit "raises a FeatureAlreadyUsedError if no feaure is alredy in arff file" do
        config = test_config
        config.instance_variable_set :@features, [@feature_name]
        use_configuration(config)

        Wikipedia::VandalismDetection::TestDataset.build!

        expect { Wikipedia::VandalismDetection::TestDataset.add_feature_to_arff!(@feature_name) }.to raise_error \
            Wikipedia::VandalismDetection::FeatureAlreadyUsedError
      end

      xit "does not raise an error if text is not extractable" do
        Wikipedia::VandalismDetection::TestDataset.build!

        error = Wikipedia::VandalismDetection::WikitextExtractionError
        Wikipedia::VandalismDetection::WikitextExtractor.any_instance.stub(:extract) { raise(error) }

        expect { Wikipedia::VandalismDetection::TestDataset.add_feature_to_arff!(@feature_name) }.not_to \
            raise_error

      end
    end

    xit "adds a feature to the existing arff file" do
      Wikipedia::VandalismDetection::TestDataset.build!
      Wikipedia::VandalismDetection::TestDataset.add_feature_to_arff!(@feature_name)

      features = @config.features
      features_count = features.include?(@feature_name) ? features.count : (features.count + 1)
      additional_header_lines = 5
      edits_count  = File.open(@training_corpus_edits_file, 'r').lines.count

      File.open(@arff_file, 'r').lines.count.should == additional_header_lines + features_count + edits_count
    end
  end
end
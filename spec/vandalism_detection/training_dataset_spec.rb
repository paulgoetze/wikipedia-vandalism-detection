require 'spec_helper'
require 'fileutils'
require 'ruby-band'

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

    it "returns a weka instances" do
      dataset = Wikipedia::VandalismDetection::TrainingDataset.build
      dataset.class.should == Java::WekaCore::Instances
    end

    describe "exceptions" do
      it "raises an EditsFileNotConfiguredError if no edits file is configured" do
        config = test_config
        config.instance_variable_set(:@training_corpus_edits_file, nil)
        use_configuration(config)

        expect { Wikipedia::VandalismDetection::TrainingDataset.build }.to raise_error \
          Wikipedia::VandalismDetection::EditsFileNotConfiguredError
      end

      it "raises an AnnotationsFileNotConfiguredError if no annotations file is configured" do
        config = test_config
        config.instance_variable_set(:@training_corpus_annotations_file, nil)
        use_configuration(config)

        expect { Wikipedia::VandalismDetection::TrainingDataset.build }.to raise_error \
          Wikipedia::VandalismDetection::AnnotationsFileNotConfiguredError
      end
    end

    Wikipedia::VandalismDetection::DefaultConfiguration::DEFAULTS['features'].each do |name|
      it "creates an arff file for the feature '#{name}'" do
        config = test_config
        config.instance_variable_set :@features, [name]
        use_configuration(config)

        file = File.join(@arff_files_dir, name.gsub(' ', '_') + '.arff')

        File.exist?(file).should be_false
        Wikipedia::VandalismDetection::TrainingDataset.build
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

      Wikipedia::VandalismDetection::TrainingDataset.build

      # anonymity should not be overwritten
      Core::Parser.parse_ARFF(anonymity_file).to_a2d.first.should == data
    end

    describe "internal algorithm" do
      before do
        @features_num = @config.features.count
      end

      it "has builds the right number of data lines" do
        dataset = Wikipedia::VandalismDetection::TrainingDataset.build
        annotations_num = File.open(@annotations_file, 'r').lines.count - 1
        additional_header_lines = 5

        dataset.to_s.lines.count.should == additional_header_lines + annotations_num + @features_num
      end

      it "builds the right number of data columns" do
        dataset = Wikipedia::VandalismDetection::TrainingDataset.build
        dataset.n_col.should == @config.features.count + 1
      end
    end
  end

  describe "#instances" do
    it "is an alias method for #build" do
      build = Wikipedia::VandalismDetection::TrainingDataset.build
      instances = Wikipedia::VandalismDetection::TrainingDataset.instances

      build.should.to_s == instances.to_s
    end
  end

  describe "#balanced_instances" do

    before do
      config = test_config
      config.instance_variable_set(:@training_data_options, 'balanced')
      use_configuration(config)

      @dataset = Wikipedia::VandalismDetection::TrainingDataset.balanced_instances
    end

    it "returns a weka dataset" do
      @dataset.class.should == Java::WekaCore::Instances
    end

    it "returns a dataset built from the configured corpus" do
      # 2 vandalism, 2 regular, see resources/corpora/training/annotations.csv
      @dataset.n_rows.should == 4
    end

    [:VANDALISM, :REGULAR].each do |class_const|
      it "has 2 '#{class_const.downcase}' samples in its instances" do
        class_count = @dataset.enumerate_instances.reduce(0) do |count, instance|
          label = Wikipedia::VandalismDetection::Instances::CLASSES[instance.class_value.to_i]
          (label == Wikipedia::VandalismDetection::Instances::const_get(class_const)) ? (count + 1) : count
        end

        class_count.should == 2
      end
    end
  end

  describe "#oversampled_instances" do
    describe "with default options" do
      before do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'oversampled')
        use_configuration(config)

        @dataset = Wikipedia::VandalismDetection::TrainingDataset.oversampled_instances # default -P 100 -U true
      end

      it "returns a weka dataset" do
        @dataset.class.should == Java::WekaCore::Instances
      end

      it "returns a dataset of size 8 built from the configured corpus" do
        # 4 vandalism, 4 regular, see resources/corpora/training/annotations.csv
        @dataset.n_rows.should == 8
      end

      [:VANDALISM, :REGULAR].each do |class_const|
        it "has 4 '#{class_const.downcase}' samples in its instances" do
          class_count = @dataset.enumerate_instances.reduce(0) do |count, instance|
            label = Wikipedia::VandalismDetection::Instances::CLASSES[instance.class_value.to_i]
            (label == Wikipedia::VandalismDetection::Instances::const_get(class_const)) ? (count + 1) : count
          end

          class_count.should == 4
        end
      end

      it "returns a dataset of size 8 for 200% 'SMOTEING' built from the configured corpus" do
        # 4 vandalism, 4 regular, see resources/corpora/training/annotations.csv
        dataset = Wikipedia::VandalismDetection::TrainingDataset.oversampled_instances(percentage: 200)
        puts dataset
        dataset.n_rows.should == 8
      end
    end

    describe "with custom options" do
      before do
        config = test_config
        config.instance_variable_set(:@training_data_options, 'oversampled -p 300 -u false')
        use_configuration(config)

        @dataset = Wikipedia::VandalismDetection::TrainingDataset.oversampled_instances
      end

      it "returns a weka dataset" do
        @dataset.class.should == Java::WekaCore::Instances
      end

      it "returns a dataset of size 12 built from the configured corpus" do
        # 2 + 300 % = 8 vandalism, 4 regular, see resources/corpora/training/annotations.csv
        puts @dataset
        @dataset.n_rows.should == 12
      end
    end
  end

  describe "#create_corpus_index_file!" do

    it "responds to #create_corpus_file_index!" do
      Wikipedia::VandalismDetection::TrainingDataset.should respond_to(:create_corpus_file_index!)
    end

    describe "exceptions" do

      it "raises an RevisionsDirectoryNotConfiguredError if no revisions directory is configured" do
        config = test_config
        config.instance_variable_set :@training_corpus_revisions_directory, nil
        use_configuration(config)

        expect { Wikipedia::VandalismDetection::TrainingDataset.create_corpus_file_index! }.to raise_error \
          Wikipedia::VandalismDetection::RevisionsDirectoryNotConfiguredError
      end
    end

    it "creates a corpus_index.yml file in the build directory" do
      File.exist?(@index_file).should be_false
      Wikipedia::VandalismDetection::TrainingDataset.create_corpus_file_index!
      File.exist?(@index_file).should be_true
    end
  end
end
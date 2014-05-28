require 'spec_helper'

describe Wikipedia::VandalismDetection::Evaluator do

  before do
    use_test_configuration
    @config = test_config

    @training_arff_file = @config.training_output_arff_file
    @test_arff_file = @config.test_output_arff_file
    @build_dir = @config.output_base_directory
    @test_classification_file = @config.test_output_classification_file
  end

  after do
    # remove training arff file
    if File.exists?(@training_arff_file)
      File.delete(@training_arff_file)
      FileUtils.rm_r(File.dirname @training_arff_file)
    end

    # remove test arff file
    if File.exists?(@test_arff_file)
      File.delete(@test_arff_file)
      FileUtils.rm_r(File.dirname @test_arff_file)
    end

    # remove classification.txt
    if File.exist?(@test_classification_file)
      File.delete(@test_classification_file)
      File.rm_r(File.dirname @test_classification_file)
    end

    # remove output base directory
    if Dir.exists?(@build_dir)
      FileUtils.rm_r(@build_dir)
    end
  end

  describe "#initialize" do

    it "raises an ArgumentError if classifier attr is not of Wikipedia::VandalismDetection::Classfier" do
      expect { Wikipedia::VandalismDetection::Evaluator.new("") }.to raise_error ArgumentError
    end

    it "does not raise an error while appropriate initialization" do
      classifier = Wikipedia::VandalismDetection::Classifier.new
      expect { Wikipedia::VandalismDetection::Evaluator.new(classifier) }.not_to raise_error
    end
  end

  before do
    classifier = Wikipedia::VandalismDetection::Classifier.new
    @evaluator = Wikipedia::VandalismDetection::Evaluator.new(classifier)
  end

  describe "#test_performance_curves" do

    before do
      @classification = {
          :"1-2" => {
              old_revision_id: 1,
              new_revision_id: 2,
              class: "R",
              confidence: 0.0
          },
          :"2-3" => {
              old_revision_id: 2,
              new_revision_id: 3,
              class: "R",
              confidence: 0.3
          },
          :"3-4" => {
              old_revision_id: 3,
              new_revision_id: 4,
              class: "V",
              confidence: 0.8
          },
          :"4-5" => {
              old_revision_id: 4,
              new_revision_id: 5,
              class: "V",
              confidence: 1.0
          }
      }

      # ground truth has one sample more to represent fall-out samples while feature calculation
      # (e.g. redirects are not considered)
      @ground_truth = {
          :"0-1" => { # this is a sample that is not used!
              old_revision_id: 0,
              new_revision_id: 1,
              class: "R"
          },
          :"1-2" => {
              old_revision_id: 1,
              new_revision_id: 2,
              class: "R"
          },
          :"2-3" => {
              old_revision_id: 2,
              new_revision_id: 3,
              class: "V"
          },
          :"3-4" => {
              old_revision_id: 3,
              new_revision_id: 4,
              class: "R"
          },
          :"4-5" => {
              old_revision_id: 4,
              new_revision_id: 5,
              class: "V"
          }
      }

      @sample_count = 10

      @curve_data = @evaluator.test_performance_curves(@ground_truth, @classification, @sample_count)
    end

    it "returns a Hash" do
      @curve_data.should be_a Hash
    end

    [:recalls, :precisions,:fp_rates, :pr_auc, :roc_auc].each do |attribute|
      it "returns a Hash including #{attribute}" do
        @curve_data.should have_key(attribute)
      end
    end

    [:recalls, :precisions,:fp_rates].each do |attribute|
      it "returns a Hash including #{attribute} of length #{@sample_count}" do
        @curve_data[attribute].count.should == @sample_count
      end
    end

    describe "#predictive_values" do

      before do
        @threshold = 0.5
        @predictive_values = @evaluator.predictive_values(@ground_truth, @classification, @threshold)
      end

      it "returns a Hash" do
        @predictive_values.should be_a Hash
      end

      [
          { threshold: 0.0, result: {tp: 2, fp: 2, tn: 0, fn: 0} },
          { threshold: 0.3, result: {tp: 1, fp: 1, tn: 1, fn: 1} },
          { threshold: 0.5, result: {tp: 1, fp: 1, tn: 1, fn: 1} },
          { threshold: 0.8, result: {tp: 1, fp: 1, tn: 1, fn: 1} },
          { threshold: 0.9, result: {tp: 1, fp: 0, tn: 2, fn: 1} },
          { threshold: 1.0, result: {tp: 0, fp: 0, tn: 2, fn: 2} }
      ].each do |values|
        it "returns the right values for threshold #{values[:threshold]}" do
          predictive_values = @evaluator.predictive_values(@ground_truth, @classification, values[:threshold])
          predictive_values.should == values[:result]
        end
      end
    end

    describe "#area_under_curve" do

      before do
        precisions = @curve_data[:precisions]
        recalls = @curve_data[:precisions]
        fp_rates = @curve_data[:fp_rates]

        @pr_auc = @evaluator.area_under_curve(recalls, precisions)
        @roc_auc = @evaluator.area_under_curve(fp_rates, recalls)
      end

      it "returns a numeric value for pr_auc" do
        @pr_auc.should be_a Numeric
      end

      it "returns a numeric value between 0.0 & 1.0 for pr_auc" do
        is_between_zero_and_one = (@pr_auc >= 0.0 && @pr_auc <= 1.0)
        is_between_zero_and_one.should be_true
      end

      it "returns a numeric value for roc_auc" do
        @roc_auc.should be_a Numeric
      end

      it "returns a numeric value between 0.0 & 1.0 for roc_auc" do
        is_between_zero_and_one = @roc_auc >= 0.0 && @roc_auc <= 1.0
        is_between_zero_and_one.should be_true
      end

      [
          { x: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0], y: [1.0, 0.8, 0.6, 0.4, 0.2, 0.0], auc: 0.5 }
      ].each do |data|
        it "returns the right values" do
          x = data[:x]
          y = data[:y]
          auc = data[:auc]

          @evaluator.area_under_curve(x, y).should == auc
        end
      end

    end
  end

  describe "#create_testcorpus_classification_file!" do

    before do
      @ground_truth = { # see resources file ground_truth.csv
          :"0-1" => { # this is a sample that is not used!
              old_revision_id: 0,
              new_revision_id: 1,
              class: "R"
          },
          :"307084144-326873205" => {
              old_revision_id: 307084144,
              new_revision_id: 326873205,
              class: "R"
          },
          :"326471754-326978767" => {
              old_revision_id: 326471754,
              new_revision_id: 326978767,
              class: "V"
          },
          :"328774035-328774110" => {
              old_revision_id: 328774035,
              new_revision_id: 328774110,
              class: "R"
          }
      }
    end

    it "raises an argument error if ground_truth param is nil" do
      expect { @evaluator.create_testcorpus_classification_file!(@test_classification_file, nil) }.to raise_error ArgumentError
    end

    it "creates a classification file in the base output directory" do
      File.exists?(@test_classification_file).should be_false
      @evaluator.create_testcorpus_classification_file!(@test_classification_file, @ground_truth)
      File.exists?(@test_classification_file).should be_true
    end

    it "creates a file with an appropriate header" do
      @evaluator.create_testcorpus_classification_file!(@test_classification_file, @ground_truth)
      content = File.open(@test_classification_file, 'r')

      features = Core::Parser.parse_ARFF(@test_arff_file).enumerate_attributes.to_a.map { |attr| attr.name.upcase }[0...-2]
      proposed_header = ['OLDREVID', 'NEWREVID', 'C', 'CONF', *features]
      header = content.lines.first.split(' ')

      header.should == proposed_header
    end

    it "creates a file with an appropriate number of lines" do
      @evaluator.create_testcorpus_classification_file!(@test_classification_file, @ground_truth)
      content = File.open(@test_classification_file, 'r')

      samples_count = Core::Parser.parse_ARFF(@test_arff_file).n_rows

      lines = content.lines.to_a
      lines.shift # remove header
      lines.count.should == samples_count
    end
  end

  describe "#evaluate_testcorpus_classification" do

    describe "exceptions" do

      it "raises an GroundTruthFileNotConfiguredError unless a ground thruth file is configured" do
        config = test_config
        config.instance_variable_set :@test_corpus_ground_truth_file, nil
        use_configuration(config)

        classifier = Wikipedia::VandalismDetection::Classifier.new
        evaluator = Wikipedia::VandalismDetection::Evaluator.new(classifier)

        expect { evaluator.evaluate_testcorpus_classification }.to raise_error \
          Wikipedia::VandalismDetection::GroundTruthFileNotConfiguredError
      end

      it "raises an GroundTruthFileNotFoundError unless the ground thruth file can be found" do
        config = test_config
        config.instance_variable_set :@test_corpus_ground_truth_file, 'false-file-name.txt'
        use_configuration(config)

        classifier = Wikipedia::VandalismDetection::Classifier.new
        evaluator = Wikipedia::VandalismDetection::Evaluator.new(classifier)

        expect { evaluator.evaluate_testcorpus_classification }.to raise_error \
          Wikipedia::VandalismDetection::GroundTruthFileNotFoundError
      end
    end

    it "returns a performance values Hash" do
      performance_values = @evaluator.evaluate_testcorpus_classification(sample_count: @sample_count)
      performance_values.should be_a Hash
    end

    [ :fp_rates,
      :precisions,
      :recalls,
      :pr_auc,
      :roc_auc,
      :total_precision,
      :total_recall
    ].each do |attr|
      it "returns a performance values Hash with property'#{attr}'" do
        performance_values = @evaluator.evaluate_testcorpus_classification(sample_count: @sample_count)
        performance_values[attr].should_not be_nil
      end
    end

    it "runs the classification file creation" do
      File.exists?(@test_classification_file).should be_false
      @evaluator.evaluate_testcorpus_classification
      File.exists?(@test_classification_file).should be_true
    end

    it "overwrites the old classification file" do
      config = test_config

      config.instance_variable_set(:@features, ['comment length'])
      use_configuration(config)

      classifier = Wikipedia::VandalismDetection::Classifier.new
      evaluator = Wikipedia::VandalismDetection::Evaluator.new(classifier)

      evaluator.evaluate_testcorpus_classification
      content_old = File.read(@test_classification_file)

      config.instance_variable_set(:@features, ['anonymity'])
      use_configuration(config)

      classifier = Wikipedia::VandalismDetection::Classifier.new
      evaluator = Wikipedia::VandalismDetection::Evaluator.new(classifier)

      evaluator.evaluate_testcorpus_classification
      content_new = File.read(@test_classification_file)

      content_old.should_not == content_new
    end
  end

  describe "#cross_validate" do

    it "returns an evaluation object" do
      evaluation = @evaluator.cross_validate
      evaluation.class.should == Java::WekaClassifiers::Evaluation
    end

    it "can cross validates the classifier" do
      expect { @evaluator.cross_validate }.not_to raise_error
    end

    it "can cross validates the classifier with equally distributed samples" do
      expect { @evaluator.cross_validate(equally_distributed: true) }.not_to raise_error
    end
  end

  describe "#curve_data" do

    describe "all samples" do

      before do
        @data = @evaluator.curve_data
      end

      it "returns a Hash" do
        @data.should be_a Hash
      end

      it "includes precision curve data" do
        @data[:precision].should be_a Array
      end

      it "includes recall curve data" do
        @data[:recall].should be_a Array
      end

      it "includes area_under_prc data" do
        @data[:area_under_prc].should be_a Numeric
      end

      it "has non-empty :precision Array contents" do
        @data[:precision].should_not be_empty
      end

      it "has non-empty :recall Array contents" do
        @data[:recall].should_not be_empty
      end
    end

    describe "equally distributed samples" do

      before do
        @data = @evaluator.curve_data(equally_distributed: true)
      end

      it "returns a Hash" do
        @data.should be_a Hash
      end

      it "includes precision curve data" do
        @data[:precision].should be_a Array
      end

      it "includes recall curve data" do
        @data[:recall].should be_a Array
      end

      it "includes area_under_prc data" do
        @data[:area_under_prc].should be_a Numeric
      end

      it "has non-empty :precision Array contents" do
        @data[:precision].should_not be_empty
      end

      it "has non-empty :recall Array contents" do
        @data[:recall].should_not be_empty
      end
    end
  end

  describe "#feature_analysis" do

    it "returns a hash" do
      analysis = @evaluator.feature_analysis(sample_count: 100)
      analysis.should be_a Hash
    end

    it "returns a hash with feature count size" do
      analysis = @evaluator.feature_analysis(sample_count: 100)
      analysis.count.should == @config.features.count
    end

    it "returns a hash with sample count number of data hashes" do
      sample_count = 5
      analysis = @evaluator.feature_analysis(sample_count: sample_count)

      analysis.each do |key, threshold_hash|
        threshold_hash.count.should == sample_count
      end
    end

    it "returns the four predictive values in each features threshold hash" do
      analysis = @evaluator.feature_analysis
      threshold_hash = analysis[@config.features.first][0.0]

      threshold_hash.should have_key(:fp)
      threshold_hash.should have_key(:fn)
      threshold_hash.should have_key(:tp)
      threshold_hash.should have_key(:tn)
    end
  end

  describe "#full_analysis" do

    it "returns a hash" do
      analysis = @evaluator.full_analysis(sample_count: 100)
      analysis.should be_a Hash
    end

    it "returns a hash with smaple count number of threshold hashes" do
      sample_count = 5
      analysis = @evaluator.full_analysis(sample_count: sample_count)
      analysis.count.should == sample_count
    end

    it "returns the four predictive values in each features threshold hash" do
      analysis = @evaluator.full_analysis
      threshold_hash = analysis[0.0]

      threshold_hash.should have_key(:fp)
      threshold_hash.should have_key(:fn)
      threshold_hash.should have_key(:tp)
      threshold_hash.should have_key(:tn)
    end
  end
end
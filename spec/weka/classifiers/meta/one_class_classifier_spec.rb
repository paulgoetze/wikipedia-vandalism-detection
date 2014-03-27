require 'spec_helper'

describe Weka::Classifiers::Meta::OneClassClassifier do

  it { should be_a Java::WekaClassifiersMeta::OneClassClassifier }

  before do
    @config = {
        "source"    => source_dir,
        'features'  => [
            "anonymity"
        ],
        "training_corpus" => paths[:training_corpus],
        "classifier" => {
            "type"    => 'Meta::OneClassClassifier',
            "options" => "-tcl #{Wikipedia::VandalismDetection::Instances::VANDALISM}",
            "cross-validation-fold" => 2
        }
    }

    use_configuration(@config)
  end

  after do
    arff_file = @config["training_corpus"]["arff_file"]
    build_dir = "#{@config['source']}/build"

    if File.exists?(arff_file)
      File.delete(arff_file)
      FileUtils.rm_r(File.dirname arff_file)
    end

    if Dir.exists?(build_dir)
      FileUtils.rm_r(build_dir)
    end
  end

  it "can be used to classifiy vandalism" do
    expect {
      classifier = Wikipedia::VandalismDetection::Classifier.new
      classifier.cross_validate
    }.not_to raise_error
  end
end
module TestConfiguration
  require 'yaml'

  SOURCE_DIR = File.expand_path('../../../../spec/resources/', __FILE__)

  def source_dir
    SOURCE_DIR
  end

  def use_configuration(override)
    Wikipedia::VandalismDetection.stub(configuration: override)
  end

  def use_test_configuration
    use_configuration(test_config)
  end

  def use_default_configuration
    use_configuration(Wikipedia::VandalismDetection::DefaultConfiguration::DEFAULTS)
  end

  def test_configuration_content
    puts File.join(SOURCE_DIR, 'config/wikipedia-vandalism-detection.yml')
    YAML.load_file(File.join(source_dir, 'config/wikipedia-vandalism-detection.yml'))
  end

  def merged_configuration(override = test_configuration_content)
    default_config = Wikipedia::VandalismDetection::DefaultConfiguration::DEFAULTS.merge({'source' => source_dir})
    default_config.deep_merge(override)
  end

  def test_config
    Wikipedia::VandalismDetection::DefaultConfiguration.any_instance.stub(source: source_dir)
    Wikipedia::VandalismDetection::Configuration.send(:new)
  end

  def paths
    config = test_configuration_content
    corpus_config = config["corpora"]
    output_config = config["output"]

    {
        corpora: {
            "base_directory" => File.expand_path(corpus_config['base_directory'], __FILE__),
            "training" => {
                "base_directory" => "training",
                "edits_file" => corpus_config["training"]["edits_file"],
                "annotations_file" => corpus_config["training"]["annotations_file"],
                "revisions_directory" => corpus_config["training"]["revisions_directory"]
            },
            "test" => {
                "base_directory" => "test",
                "edits_file" => corpus_config["test"]["edits_file"],
                "revisions_directory" => corpus_config["test"]["revisions_directory"]
            }

        },
        output: {
            "base_directory" => File.expand_path(output_config['base_directory'], __FILE__),
            "training" => {
                "index_file" => output_config["training"]["index_file"],
                "arff_file" => output_config["training"]["arff_file"]
            },
              "test" =>  {
                  "index_file" => output_config["test"]["index_file"],
                  "arff_file" => output_config["test"]["arff_file"]
            }
        }
    }
  end
end
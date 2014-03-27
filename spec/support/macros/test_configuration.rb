module TestConfiguration
  require 'yaml'

  SOURCE_DIR = File.expand_path '../../../resources/', __FILE__

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
    use_configuration(Wikipedia::VandalismDetection::Configuration::DEFAULTS)
  end

  def test_configuration_content
    puts File.join(SOURCE_DIR, 'config/config.yml')
    YAML.load_file(File.join(source_dir, 'config/config.yml'))
  end

  def merged_configuration(override = test_configuration_content)
    default_config = Wikipedia::VandalismDetection::Configuration::DEFAULTS.merge({'source' => source_dir})
    default_config.deep_merge(override)
  end

  def test_config
    Wikipedia::VandalismDetection::Configuration.any_instance.stub(source: source_dir)

    config = test_configuration_content
    config = config.merge( { "training_corpus" => paths[:training_corpus] })

    merged_configuration(config)
  end

  def paths
    config = test_configuration_content
    corpus_data = config["training_corpus"]

    {
        training_corpus: {
            "index_file" => File.expand_path('../../../resources/build/corpus_index.yml', __FILE__),
            "arff_file" => File.expand_path(corpus_data["arff_file"], __FILE__),
            "edits_file" => File.expand_path(corpus_data["edits_file"], __FILE__),
            "annotations_file" => File.expand_path(corpus_data["annotations_file"], __FILE__),
            "revisions_directory" => File.expand_path(corpus_data["revisions_directory"], __FILE__)
        }
    }
  end
end
module TestConfiguration
  require 'yaml'

  SOURCE_DIR = File.expand_path('../../../../spec/resources/', __FILE__)
  CONFIG_DEFAULTS = Wikipedia::VandalismDetection::DefaultConfiguration::DEFAULTS

  def source_dir
    SOURCE_DIR
  end

  def use_configuration(override)
    allow(Wikipedia::VandalismDetection)
      .to receive(:config)
      .and_return(override)
  end

  def use_test_configuration
    use_configuration(test_config)
  end

  def use_default_configuration
    use_configuration(CONFIG_DEFAULTS)
  end

  def test_configuration_content
    config_file = 'config/wikipedia-vandalism-detection.yml'
    config_path = File.join(source_dir, config_file)
    YAML.load_file(config_path)
  end

  def merged_configuration(override = test_configuration_content)
    default_config = CONFIG_DEFAULTS.merge('source' => source_dir)
    default_config.deep_merge(override)
  end

  def test_config
    allow_any_instance_of(Wikipedia::VandalismDetection::DefaultConfiguration)
      .to receive(:source)
      .and_return(source_dir)

    Wikipedia::VandalismDetection::Configuration.send(:new)
  end

  def paths
    config = test_configuration_content
    corpus_config = config['corpora']

    base_directory = File.expand_path(corpus_config['base_directory'], __FILE__)
    training = corpus_config['training']
    test = corpus_config['test']

    {
      corpora: {
        'base_directory' => base_directory,
        'training' => {
          'base_directory' => 'training',
          'edits_file' => training['edits_file'],
          'annotations_file' => training['annotations_file'],
          'revisions_directory' => training['revisions_directory']
        },
        'test' => {
          'base_directory' => 'test',
          'edits_file' => test['edits_file'],
          'revisions_directory' => test['revisions_directory']
        }

      },
      output: {
        'base_directory' => base_directory,
        'training' => {
          'index_file' => training['index_file'],
          'arff_file' => training['arff_file']
        },
        'test' => {
          'index_file' => test['index_file'],
          'arff_file' => test['arff_file']
        }
      }
    }
  end
end

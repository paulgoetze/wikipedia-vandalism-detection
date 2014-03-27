module Wikipedia
  module VandalismDetection

    require 'yaml'

    def self.configuration
      config = Configuration[Configuration::DEFAULTS]
      @config_from_file ||= config.load_config_file(config.config_file)

      @configuration ||= (@config_from_file ? config.deep_merge(@config_from_file) : config)
    end

    class Configuration < Hash
      DEFAULTS = {
          "source"    => Dir.pwd,
          'features'  => [
              "anonymity",
              "biased frequency",
              "biased impact",
              "character sequence",
              "comment length",
              "compressibility",
              "longest word",
              "pronoun frequency",
              "pronoun impact",
              "replacement similarity",
              "size ratio",
              "term frequency",
              "upper case ratio",
              "upper to lower case ratio",
              "vulgarism frequency",
              "vulgarism impact"
          ],
          "training_corpus" => {
              "index_file"          => File.join(Dir.pwd, 'build/corpus_file_index.yml'),
              "edits_file"          => nil,
              "annotations_file"    => nil,
              "revisions_directory" => nil,
              "arff_file"           => File.join(Dir.pwd, 'data/training-data.arff')
          },
          "classifier" => {
              "type"    => nil,
              "options" => nil,
              "cross-validation-fold" => 10
          }
      }

      def source
        DEFAULTS['source']
      end

      # Looks in two places for a custom config file:
      # in <app_root>/config/ and in <app_root>/lib/config
      def config_file
        root_file = File.join(source, "config/config.yml")
        lib_file = File.join(source, "lib/config/config.yml")

        File.exist?(root_file) ? root_file : lib_file
      end

      def load_config_file(file)
        if File.exists? file
          YAML.load_file(file)
        else
          warn %Q{

            Configuration file not found in #{source}/config or #{source}/lib/config directory.
            To customize the system, create a config.yml file.

          }
        end
      end
    end
  end
end

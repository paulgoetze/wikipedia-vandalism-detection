require 'find'
require 'yaml'
require 'fileutils'
require 'csv'
require 'ruby-band'

require 'wikipedia/vandalism_detection/configuration'
require 'wikipedia/vandalism_detection/text'
require 'wikipedia/vandalism_detection/revision'
require 'wikipedia/vandalism_detection/edit'
require 'wikipedia/vandalism_detection/feature_calculator'
require 'wikipedia/vandalism_detection/instances'
require 'wikipedia/vandalism_detection/wikitext_extractor'

module Wikipedia
  module VandalismDetection

    # This class provides methods for getting and creating a test ARFF file from a configured test corpus.
    class TestDataset

      def self.instances
        build!
      end

      # Builds the dataset as ARFF file which can be used by an Evaluator.
      # As test data it uses the configured data corpus from /config/config.yml.
      def self.build!
        @config = Wikipedia::VandalismDetection.configuration
        feature_calculator = FeatureCalculator.new
        create_dataset!(feature_calculator)
      end

      # Creates and returns an instance dataset from the configured gold annotation file using the
      # configured features from feature_calculator parameter.
      def self.create_dataset!(feature_calculator)
        print "\ncreating test dataset..."

        edits_file = @config.test_corpus_edits_file
        raise EditsFileNotConfiguredError unless edits_file

        edits = CSV.parse(File.read(edits_file), headers: true)

        output_directory = File.join(@config.output_base_directory, 'test')
        FileUtils.mkdir_p(output_directory) unless Dir.exists?(output_directory)
        FileUtils.mkdir_p(@config.output_base_directory) unless Dir.exists?(@config.output_base_directory)

        # create feature file hash with io objects
        feature_files = @config.features.inject({}) do |hash, feature_name|
          file_name = "#{feature_name.gsub(' ', '_').downcase}.arff"
          arff_file = File.join(output_directory, file_name)

          unless File.exists?(arff_file)
            dataset = Instances.empty_for_test_feature(feature_name)
            dataset.to_ARFF(arff_file)
            hash[feature_name] = File.open(arff_file, 'a')
          end

          hash
        end

        unless feature_files.empty?
          processed_edits = 0
          edits_count = edits.count

          edits.each do |edit_data|
            old_revision_id = edit_data['oldrevisionid']
            new_revision_id = edit_data['newrevisionid']

            processed_edits += 1
            print_progress(processed_edits, edits_count, "computing test features")

            next unless (annotated_revision?(old_revision_id) && annotated_revision?(new_revision_id))
            edit = create_edit_from(edit_data)

            feature_files.each do |feature_name, file|
              value = feature_calculator.calculate_feature_for(edit, feature_name)
              file.puts [value, old_revision_id, new_revision_id].join(',')
            end
          end

          # close all io objects
          feature_files.each do |feature_name, file|
            file.close
            puts "\n'#{File.basename(file.path)}' saved to #{File.dirname(file.path)}"
          end
        end

        merged_dataset = merge_feature_arffs(@config.features, output_directory)

        output_file = @config.training_output_arff_file
        merged_dataset.to_ARFF(output_file)
        puts "\n'#{File.basename(output_file)}' saved to #{File.dirname(output_file)}"

        merged_dataset
      end

      # Loads arff files of given features and merge them into one arff file.
      # Returns the merged arff file.
      def self.merge_feature_arffs(features, output_directory)
        filter = Weka::Filters::Unsupervised::Attribute::Remove.new
        merged_dataset = nil

        features.each do |feature_name|
          file_name = "#{feature_name.gsub(' ', '_').downcase}.arff"
          arff_file = File.join(output_directory, file_name)

          feature_dataset = Core::Parser.parse_ARFF(arff_file)
          puts "using #{File.basename(arff_file)}"

          if merged_dataset
            2.times do
              filter.set do
                data merged_dataset
                filter_options '-R last'
              end

              merged_dataset = filter.use
            end

            merged_dataset = merged_dataset.merge_with(feature_dataset)
          else
            merged_dataset = feature_dataset
          end
        end

        merged_dataset
      end

      # Saves and returns a file index hash of structure [file_name => full_path] for the given directory.
      def self.create_corpus_file_index!
        @config = Wikipedia::VandalismDetection.configuration
        revisions_directory = @config.test_corpus_revisions_directory

        raise RevisionsDirectoryNotConfiguredError unless revisions_directory

        print "\nCreating test corpus index file..."
        file_index = {}

        Dir.open revisions_directory do |part_directories|
          part_directories.each do |part_directory|
            Dir.open "#{revisions_directory}/#{part_directory}" do |contents|
              contents.each do |file|
                path = "#{revisions_directory}/#{part_directory}/#{file}"

                if File.file?(path) && (file =~ /\d+.txt/) && annotated_revision?(file)
                  file_index[file] = path
                  print "\r processed #{file_index.count } files"
                end
              end
            end
          end
        end

        file = @config.test_output_index_file
        dirname = File.dirname(file)
        FileUtils.mkdir(dirname) unless Dir.exists?(dirname)

        written = File.open(file, 'w') { |f| f.write(file_index.to_yaml) }
        print "\nSaved test corpus index file to #{file}.\n" if written > 0

        file_index
      end

      # Returns whether the
      def self.annotated_revision?(revision_file)
        @annotated_revisions ||= annotated_revisions

        revision_id = revision_file.gsub('.txt', '')
        @annotated_revisions[revision_id.to_sym]
      end

      # Returns a Hash with the used revision ids from edits_file.
      def self.annotated_revisions
        annotations_file = @config.test_corpus_ground_truth_file
        annotations = File.read(annotations_file).lines

        annotated_revisions = {}

        annotations.each do |annotation|
          data = annotation.split(' ')

          annotated_revisions[data[0].to_sym] = true
          annotated_revisions[data[1].to_sym] = true
        end

        @annotated_revisions ||= annotated_revisions
      end

      # Removes instances including -1 values
      def self.remove_invalid_instances(dataset)
        filter = Weka::Filters::Unsupervised::Instance::RemoveWithValues.new

        filter.set do
          data dataset
          filter_options '-S 0 -V'
        end

        filter.use
      end

      # Creates a Wikipedia::Edit out of an edit's data from edit_file configured in config.yml
      def self.create_edit_from(edit_data)
        @file_index ||= load_corpus_file_index

        old_revision_id = edit_data['oldrevisionid'].to_i
        new_revision_id = edit_data['newrevisionid'].to_i

        editor = edit_data['editor']
        comment = edit_data['editcomment']
        new_timestamp = edit_data['edittime']

        old_revision_file = @file_index["#{old_revision_id}.txt"]
        new_revision_file = @file_index["#{new_revision_id}.txt"]

        raise(RevisionFileNotFound, "Old revision file #{old_revision_file} not found") unless \
          File.exist?(old_revision_file)
        raise(RevisionFileNotFound, "New revision file #{new_revision_file} not found") unless \
          File.exist?(new_revision_file)

        old_revision_text = File.read(old_revision_file)
        new_revision_text = File.read(new_revision_file)

        old_revision = Revision.new
        old_revision.id = old_revision_id
        old_revision.text = Text.new(old_revision_text)

        new_revision = Revision.new
        new_revision.id = new_revision_id
        new_revision.text = Text.new(new_revision_text)
        new_revision.parent_id = old_revision_id
        new_revision.comment = Text.new(comment)
        new_revision.contributor = editor
        new_revision.timestamp = new_timestamp

        Edit.new old_revision, new_revision
      end

      # Gets or creates the corpus index file, which holds a hash of revision files name and their path
      # in the article revisions directory.
      def self.load_corpus_file_index
        index_file = @config.test_output_index_file

        if File.exists? index_file
          puts " (Using #{index_file}) \n"
          YAML.load_file index_file
        else
          create_corpus_file_index!
        end
      end

      # Prints the progress to the $stdout
      def self.print_progress(processed_count, total_count, message)
        processed_absolute = "#{processed_count}/#{total_count}"
        processed_percentage = "%0.2f%" % ((processed_count * 100.00) / total_count).round(2)
        print "\r#{message}... #{processed_absolute} | #{processed_percentage}"
      end

      private_class_method :annotated_revision?,
                           :annotated_revisions,
                           :remove_invalid_instances,
                           :create_edit_from,
                           :load_corpus_file_index,
                           :print_progress
    end
  end
end
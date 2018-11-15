require 'find'
require 'yaml'
require 'fileutils'
require 'csv'
require 'weka'

require 'wikipedia/vandalism_detection/configuration'
require 'wikipedia/vandalism_detection/text'
require 'wikipedia/vandalism_detection/revision'
require 'wikipedia/vandalism_detection/edit'
require 'wikipedia/vandalism_detection/feature_calculator'
require 'wikipedia/vandalism_detection/instances'
require 'wikipedia/vandalism_detection/wikitext_extractor'

module Wikipedia
  module VandalismDetection
    # This class provides methods for getting and creating a test ARFF file from
    # a configured test corpus.
    class TestDataset
      class << self
        # Returns an instance dataset from the configured gold annotation file
        # using the configured features from feature_calculator parameter.
        def build
          @config = Wikipedia::VandalismDetection.config
          print "\ncreating test dataset…"

          edits_file = @config.test_corpus_edits_file
          raise EditsFileNotConfiguredError unless edits_file

          edits = CSV.parse(File.read(edits_file), headers: true)

          output_directory = File.join(@config.output_base_directory, 'test')

          unless Dir.exist?(output_directory)
            FileUtils.mkdir_p(output_directory)
          end

          unless Dir.exist?(@config.output_base_directory)
            FileUtils.mkdir_p(@config.output_base_directory)
          end

          # create feature file hash with io objects
          feature_files = @config.features.each_with_object({}) do |feature_name, hash|
            file_name = "#{feature_name.tr(' ', '_').downcase}.arff"
            arff_file = File.join(output_directory, file_name)

            next if File.exist?(arff_file)

            dataset = Instances.empty_for_test_feature(feature_name)
            dataset.to_arff(arff_file)
            hash[feature_name] = File.open(arff_file, 'a')
          end

          feature_calculator = FeatureCalculator.new

          unless feature_files.empty?
            processed_edits = 0
            edits_count = edits.count

            edits.each do |edit_data|
              old_revision_id = edit_data['oldrevisionid']
              new_revision_id = edit_data['newrevisionid']

              processed_edits += 1
              print_progress(processed_edits, edits_count, 'computing test features')

              annotated_old_revision = annotated_revision?(old_revision_id)
              annotated_new_revision = annotated_revision?(new_revision_id)
              next unless annotated_old_revision && annotated_new_revision

              edit = create_edit_from(edit_data)

              feature_files.each do |feature_name, file|
                value = feature_calculator.calculate_feature_for(edit, feature_name)
                file.puts [value, old_revision_id, new_revision_id].join(',')
              end
            end

            # close all io objects
            feature_files.each_value(&:close)
          end

          merge_feature_arffs(@config.features, output_directory)
        end

        alias instances build

        # Saves and returns the dataset as ARFF file.
        # As test data the configured data corpus from /config/wikipedia-vandalism-detection.yml is used.
        def build!
          @config = Wikipedia::VandalismDetection.config

          dataset     = instances
          output_file = @config.test_output_arff_file

          dataset.to_arff(output_file)
          puts "\n'#{File.basename(output_file)}' saved to #{File.dirname(output_file)}"

          dataset
        end

        # Loads arff files of given features and merge them into one arff file.
        # Returns the merged arff file.
        def merge_feature_arffs(features, output_directory)
          filter = Weka::Filters::Unsupervised::Attribute::Remove.new
          filter.use_options('-R last')

          merged_dataset = nil

          features.each do |feature_name|
            file_name = "#{feature_name.tr(' ', '_').downcase}.arff"
            arff_file = File.join(output_directory, file_name)

            feature_dataset = Weka::Core::Instances.from_arff(arff_file)
            print '.'

            if merged_dataset
              merged_dataset = merged_dataset.apply_filters(filter, filter)
              merged_dataset = Weka::Core::Instances.merge_instances(merged_dataset, feature_dataset)
            else
              merged_dataset = feature_dataset
            end
          end

          add_ground_truth_class_to(merged_dataset)
        end

        # Adds the ground truth class attribute and values to the given dataset
        # and returns the merged
        def add_ground_truth_class_to(dataset)
          config = Wikipedia::VandalismDetection.config

          arff_file     = File.join(config.output_base_directory, 'test', 'class.arff')
          class_dataset = Instances.empty_for_test_class

          if File.exist?(arff_file)
            class_dataset = Weka::Core::Instances.from_arff(arff_file)
          else
            ground_truth_file_path = config.test_corpus_ground_truth_file
            ground_truth           = ground_truth_hash(ground_truth_file_path)

            dataset.each do |instance|
              old_revision_id = instance.values[-2].to_i
              new_revision_id = instance.values[-1].to_i
              key = :"#{old_revision_id}-#{new_revision_id}"

              if ground_truth.key?(key)
                class_value = Instances::CLASSES[Instances::CLASSES_SHORT.key(ground_truth[key][:class])]
                class_dataset.add_instance([class_value || '?'])
              else
                class_dataset.add_instance(['?']) # missing
              end
            end

            class_dataset.to_arff(arff_file)
            puts "saved #{File.basename(arff_file)} to #{File.dirname(arff_file)}"
          end

          if dataset.size != class_dataset.size
            raise Exception, "Different size: #{dataset.size} vs. #{class_dataset.size}"
          end

          dataset.merge(class_dataset)
        end

        # Returns a hash for classification data from given ground truth file
        def ground_truth_hash(ground_truth_file)
          file = File.read(ground_truth_file)
          ground_truth_samples = file.lines.to_a

          ground_truth = {}

          ground_truth_samples.each do |line|
            line_parts = line.split(' ')

            old_revision_id = line_parts[0].to_i
            new_revision_id = line_parts[1].to_i
            class_short     = line_parts[2]

            ground_truth[:"#{old_revision_id}-#{new_revision_id}"] = {
              old_revision_id: old_revision_id,
              new_revision_id: new_revision_id,
              class: class_short
            }
          end

          ground_truth
        end

        # Saves and returns a file index hash of structure
        # [file_name => full_path] for the given directory.
        def create_corpus_file_index!
          @config = Wikipedia::VandalismDetection.config
          revisions_directory = @config.test_corpus_revisions_directory

          raise RevisionsDirectoryNotConfiguredError unless revisions_directory

          print "\nCreating test corpus index file…"
          file_index = {}

          Dir.open(revisions_directory) do |part_directories|
            part_directories.each do |part_directory|
              Dir.open "#{revisions_directory}/#{part_directory}" do |contents|
                contents.each do |file|
                  path = "#{revisions_directory}/#{part_directory}/#{file}"

                  if File.file?(path) && (file =~ /\d+.txt/) && annotated_revision?(file)
                    file_index[file] = path
                    print "\r processed #{file_index.count} files"
                  end
                end
              end
            end
          end

          file    = @config.test_output_index_file
          dirname = File.dirname(file)
          FileUtils.mkdir(dirname) unless Dir.exist?(dirname)

          written = File.open(file, 'w') { |f| f.write(file_index.to_yaml) }

          if written.positive?
            print "\nSaved test corpus index file to #{file}.\n"
          end

          file_index
        end

        # Returns the Edit with the given revision ids.
        # Test corpus is searched for the revisions' data.
        def edit(old_revision_id, new_revision_id)
          @config = Wikipedia::VandalismDetection.config
          edits_file = @config.test_corpus_edits_file
          raise EditsFileNotConfiguredError unless edits_file

          @edits_csv ||= CSV.parse(File.read(edits_file), headers: true)

          edit_data = @edits_csv.find do |row|
            row['oldrevisionid'] == old_revision_id &&
              row['newrevisionid'] == new_revision_id
          end

          return unless edit_data
          return unless annotated_revision?(old_revision_id)
          return unless annotated_revision?(new_revision_id)

          create_edit_from(edit_data)
        end

        private

        # Returns whether the given revision is annotated in the configured gold
        # annotation file.
        def annotated_revision?(revision_file_or_id)
          @annotated_revisions ||= annotated_revisions

          revision_id = revision_file_or_id.to_s.gsub('.txt', '')
          @annotated_revisions[revision_id.to_sym]
        end

        # Returns a Hash with the used revision ids from edits_file.
        def annotated_revisions
          annotations_file = @config.test_corpus_ground_truth_file
          annotations      = File.read(annotations_file).lines

          annotated_revisions = {}

          annotations.each do |annotation|
            data = annotation.split(' ')

            annotated_revisions[data[0].to_sym] = true
            annotated_revisions[data[1].to_sym] = true
          end

          @annotated_revisions ||= annotated_revisions
        end

        # Removes all instances with missing attributes
        def remove_missing(dataset)
          dataset.each_attribute do |attribute|
            dataset.delete_with_missing(attribute)
          end

          dataset
        end

        # Returns the normalized dataset (important for lib svm one class
        # classification)
        def normalize(dataset)
          remove = Weka::Filters::Unsupervised::Attribute::Remove.new
          remove.use_options("-V -R 1-#{@config.features.count}")
          numerics_dataset = remove.filter(dataset)

          remove.use_options("-R 1-#{@config.features.count}")
          non_numerics_dataset = remove.filter(dataset)

          normalize = Weka::Filters::Unsupervised::Attribute::Normalize.new
          normalized_dataset = normalize.filter(numerics_dataset)

          normalized_dataset.merge(non_numerics_dataset)
        end

        # Creates a Wikipedia::Edit out of an edit's data from edit_file
        # configured in wikipedia-vandalism-detection.yml
        def create_edit_from(edit_data)
          @file_index ||= load_corpus_file_index

          old_revision_id = edit_data['oldrevisionid'].to_i
          new_revision_id = edit_data['newrevisionid'].to_i

          editor        = edit_data['editor']
          comment       = edit_data['editcomment']
          new_timestamp = edit_data['edittime']
          page_id       = edit_data['articleid']
          page_title    = edit_data['articletitle']

          old_revision_file = @file_index["#{old_revision_id}.txt"]
          new_revision_file = @file_index["#{new_revision_id}.txt"]

          unless File.exist?(old_revision_file)
            message = "Old revision file #{old_revision_file} not found"
            raise RevisionFileNotFound, message
          end

          unless File.exist?(new_revision_file)
            message = "New revision file #{new_revision_file} not found"
            raise RevisionFileNotFound, message
          end

          old_revision_text = File.read(old_revision_file)
          new_revision_text = File.read(new_revision_file)

          old_revision      = Revision.new
          old_revision.id   = old_revision_id
          old_revision.text = Text.new(old_revision_text)

          new_revision             = Revision.new
          new_revision.id          = new_revision_id
          new_revision.text        = Text.new(new_revision_text)
          new_revision.parent_id   = old_revision_id
          new_revision.comment     = Text.new(comment)
          new_revision.contributor = editor
          new_revision.timestamp   = new_timestamp

          page       = Page.new
          page.id    = page_id
          page.title = page_title

          Edit.new(old_revision, new_revision, page: page)
        end

        # Gets or creates the corpus index file, which holds a hash of revision
        # files name and their path in the article revisions directory.
        def load_corpus_file_index
          index_file = @config.test_output_index_file

          if File.exist?(index_file)
            puts " (Using #{index_file}) \n"
            YAML.load_file(index_file)
          else
            create_corpus_file_index!
          end
        end

        # Prints the progress to the $stdout
        def print_progress(processed_count, total_count, message)
          processed_absolute   = "#{processed_count}/#{total_count}"
          processed_percentage = ((processed_count * 100.00) / total_count).round(2)
          print "\r#{message}… #{processed_absolute} | #{'%.2f' % processed_percentage}%"
        end
      end
    end
  end
end

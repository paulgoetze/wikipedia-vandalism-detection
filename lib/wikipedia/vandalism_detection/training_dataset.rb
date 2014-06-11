require 'find'
require 'yaml'
require 'fileutils'
require 'active_support/core_ext/string'
require 'ruby-band'

require 'wikipedia/vandalism_detection/configuration'
require 'wikipedia/vandalism_detection/text'
require 'wikipedia/vandalism_detection/revision'
require 'wikipedia/vandalism_detection/edit'
require 'wikipedia/vandalism_detection/feature_calculator'
require 'wikipedia/vandalism_detection/instances'
require 'wikipedia/vandalism_detection/wikitext_extractor'
require 'weka/filters/supervised/instance/smote'

module Wikipedia
  module VandalismDetection

    # This class provides methods for getting and creating a training ARFF file from a configured training corpus.
    class TrainingDataset

      # Returns the unbalanced dataset as given by the training arff file
      def self.instances
        config = Wikipedia::VandalismDetection.configuration
        dataset = build!

        dataset = remove_invalid_instances(dataset)
        dataset.class_index = config.features.count
        dataset
      end

      # Returns the balanced training dataset (same number of vandalism & regular instances)
      def self.balanced_instances
        dataset = instances
        filter = Weka::Filters::Supervised::Instance::SpreadSubsample.new

        #uniform distribution (remove majority instances)
        filter.set do
          data dataset
          filter_options '-M 1'
        end

        filter.use
      end

      # Returns an oversampled training dataset with more vandalism than regular edits.
      # For oversampling Weka SMOTE package is used.
      # For SMOTE method see paper: http://arxiv.org/pdf/1106.1813.pdf
      # Doc: http://weka.sourceforge.net/doc.packages/SMOTE/weka/filters/supervised/instance/SMOTE.html
      def self.oversampled_instances(options = nil)
        smote = Weka::Filters::Supervised::Instance::SMOTE.new
        dataset = instances

        smote.set do
          data dataset
          filter_options options if options
        end

        subsample = Weka::Filters::Supervised::Instance::SpreadSubsample.new

        #uniform distribution (remove majority instances)
        subsample.set do
          data smote.use
          filter_options '-M 1'
        end

        subsample.use
      end

      # Builds the dataset as ARFF file which can be used by a classifier.
      # As training data it uses the configured data corpus from /config/config.yml.
      def self.build!
        @config = Wikipedia::VandalismDetection.configuration
        feature_calculator = FeatureCalculator.new
        create_dataset!(feature_calculator)
      end

      # Creates and returns an instance dataset from the configured gold annotation file using the
      # configured features from feature_calculator parameter.
      def self.create_dataset!(feature_calculator)
        print "\ncreating training dataset..."

        annotations_file = @config.training_corpus_annotations_file
        raise AnnotationsFileNotConfiguredError unless annotations_file

        annotations = CSV.parse(File.read(annotations_file), headers: true)
        annotation_data = annotations.map { |row| { edit_id: row['editid'], class: row['class'] } }

        output_directory = File.join(@config.output_base_directory, 'training')
        FileUtils.mkdir_p(output_directory) unless Dir.exists?(output_directory)
        FileUtils.mkdir_p(@config.output_base_directory) unless Dir.exists?(@config.output_base_directory)

        # create feature file hash with io objects
        feature_files = @config.features.inject({}) do |hash, feature_name|
          file_name = "#{feature_name.gsub(' ', '_').downcase}.arff"
          arff_file = File.join(output_directory, file_name)

          unless File.exists?(arff_file)
            dataset = Instances.empty_for_feature(feature_name)
            dataset.to_ARFF(arff_file)
            hash[feature_name] = File.open(arff_file, 'a')
          end

          hash
        end

        unless feature_files.empty?
          processed_edits = 0

          annotation_data.each do |row|
            edit_id = row[:edit_id]
            vandalism = row[:class]
            edit = create_edit_from(edit_id)

            feature_files.each do |feature_name, file|
              value = feature_calculator.calculate_feature_for(edit, feature_name)
              file.puts [value, vandalism].join(',')
            end

            processed_edits += 1
            print_progress(processed_edits, @edits_csv.count, "computing training features")
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

      # Saves and returns a file index hash of structure [file_name => full_path] for the given directory.
      def self.create_corpus_file_index!
        @config = Wikipedia::VandalismDetection.configuration
        revisions_directory = @config.training_corpus_revisions_directory

        raise RevisionsDirectoryNotConfiguredError unless revisions_directory

        print "\ncreating file index..."
        file_index = {}

        Dir.open revisions_directory do |part_directories|
          part_directories.each do |part_directory|
            Dir.open "#{revisions_directory}/#{part_directory}" do |contents|
              contents.each do |file|
                path = "#{revisions_directory}/#{part_directory}/#{file}"

                if File.file?(path) && (file =~ /\d+.txt/)
                  file_index[file] = path
                  print "\r processed #{file_index.count } files"
                end
              end
            end
          end
        end

        file = @config.training_output_index_file
        dirname = File.dirname(file)
        FileUtils.mkdir(dirname) unless Dir.exists?(dirname)

        written = File.open(file, 'w') { |f| f.write(file_index.to_yaml) }
        print "\nIndex file saved to #{file}.\n" if written > 0

        file_index
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

      # Loads arff files of given features and merge them into one arff file.
      # Returns the merged arff file.
      def self.merge_feature_arffs(features, output_directory)
        filter = Weka::Filters::Unsupervised::Attribute::Remove.new
        merged_dataset = nil

        features.map do |feature_name|
          file_name = "#{feature_name.gsub(' ', '_').downcase}.arff"
          arff_file = File.join(output_directory, file_name)

          feature_dataset = Core::Parser.parse_ARFF(arff_file)
          puts "using #{File.basename(arff_file)}"

          if merged_dataset
            filter.set do
              data merged_dataset
              filter_options '-R last'
            end

            merged_dataset = filter.use
            merged_dataset = merged_dataset.merge_with(feature_dataset)
          else
            merged_dataset = feature_dataset
          end
        end

        merged_dataset
      end

      # Creates a Wikipedia::Edit out of an annotation's edit id using files form config.yml
      def self.create_edit_from(edit_id)
        @file_index ||= load_corpus_file_index
        edit_data = find_edits_data_for(edit_id)

        old_revision_id = edit_data['oldrevisionid'].to_i
        new_revision_id = edit_data['newrevisionid'].to_i

        editor = edit_data['editor']
        comment = edit_data['editcomment']
        new_timestamp = edit_data['edittime']
        page_id = edit_data['articleid']

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

        Edit.new(old_revision, new_revision, page_id)
      end

      # Gets or creates the corpus index file, which holds a hash of revision files name and their path
      # in the article revisions directory.
      def self.load_corpus_file_index
        index_file = @config.training_output_index_file

        if File.exists? index_file
          puts " (Using #{index_file}) \n"
          YAML.load_file index_file
        else
          create_corpus_file_index!
        end
      end

      # Returns the line array of the edits.csv file with given edit id.
      def self.find_edits_data_for(edit_id)
        edits_file = Wikipedia::VandalismDetection.configuration.training_corpus_edits_file
        raise EditsFileNotConfiguredError unless edits_file

        @edits_file_content ||= File.read(edits_file)
        @edits_csv ||= CSV.parse(@edits_file_content, headers: true)

        edit_data = @edits_csv.find { |row| row['editid'] == edit_id }
        raise "Edit data for edit id #{edit_id} not found in #{ File.basename(edits_file) }." unless edit_data

        edit_data
      end

      # Prints the progress to the $stdout
      def self.print_progress(processed_count, total_count, message)
        processed_absolute = "#{processed_count}/#{total_count}"
        processed_percentage = "%0.2f%" % ((processed_count * 100.00) / total_count).round(2)
        print "\r#{message}... #{processed_absolute} | #{processed_percentage}"
      end

      private_class_method :create_edit_from,
                           :merge_feature_arffs,
                           :print_progress,
                           :find_edits_data_for,
                           :load_corpus_file_index,
                           :remove_invalid_instances
    end
  end
end
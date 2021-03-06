require 'find'
require 'yaml'
require 'fileutils'
require 'active_support/core_ext/string'
require 'weka'
require 'parallel'

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
    # This class provides methods for getting and creating a training ARFF file
    # from a configured training corpus.
    class TrainingDataset
      # Returns an instance dataset from the configured gold annotation file
      # using the configured features from feature_calculator parameter.
      def self.build
        @config = Wikipedia::VandalismDetection.config

        print "\ncreating training dataset…"

        annotations_file = @config.training_corpus_annotations_file
        raise AnnotationsFileNotConfiguredError unless annotations_file

        annotations = CSV.parse(File.read(annotations_file), headers: true)

        annotation_data = annotations.map do |row|
          { edit_id: row['editid'], class: row['class'] }
        end

        output_directory = File.join(@config.output_base_directory, 'training')
        FileUtils.mkdir_p(output_directory) unless Dir.exist?(output_directory)

        unless Dir.exist?(@config.output_base_directory)
          FileUtils.mkdir_p(@config.output_base_directory)
        end

        feature_calculator = FeatureCalculator.new

        @config.features.each do |feature|
          file_name = "#{feature.tr(' ', '_').downcase}.arff"
          arff_file = File.join(output_directory, file_name)

          next if File.exist?(arff_file)

          dataset = Instances.empty_for_feature(feature)

          values = Parallel.map(annotation_data, progress: feature) do |row|
            edit_id   = row[:edit_id]
            vandalism = row[:class]
            edit      = create_edit_from(edit_id)

            value = feature_calculator.calculate_feature_for(edit, feature)
            [value, vandalism]
          end

          dataset.add_instances(values)
          dataset.to_arff(arff_file)
          puts "'#{File.basename(arff_file)}' saved to #{File.dirname(arff_file)}"
        end

        dataset = merge_feature_arffs(@config.features, output_directory)
        dataset.class_index = @config.features.count

        if @config.replace_training_data_missing_values?
          dataset = replace_missing_values(dataset)
        end

        dataset
      end

      class << self
        alias instances build
      end

      # Returns the balanced training dataset (same number of vandalism &
      # regular instances, Uniform distribution => removes majority instances)
      def self.balanced_instances
        filter = Weka::Filters::Supervised::Instance::SpreadSubsample.new
        filter.use_options('-M 1')
        filter.filter(build)
      end

      # Returns an oversampled training dataset.
      # Oversampling options can be set by using e.g:
      #   percentage: 200
      #   undersampling: false
      #
      # For oversampling Weka SMOTE package is used.
      # For SMOTE method see paper: http://arxiv.org/pdf/1106.1813.pdf
      # Doc: http://weka.sourceforge.net/doc.packages/SMOTE/weka/filters/supervised/instance/SMOTE.html
      def self.oversampled_instances(options = {})
        config          = Wikipedia::VandalismDetection.config
        default_options = config.oversampling_options

        options[:percentage]    ||= default_options[:percentage]
        options[:undersampling] ||= default_options[:undersampling]

        percentage    = options[:percentage]
        smote_options = "-P #{percentage.to_i}" if percentage

        smote = Weka::Filters::Supervised::Instance::SMOTE.new
        smote.use_options(smote_options) if smote_options
        smote_dataset = smote.filter(build)

        undersampling = options[:undersampling] / 100.0

        if undersampling > 0.0
          # balance (remove majority instances)
          subsample = Weka::Filters::Supervised::Instance::SpreadSubsample.new
          subsample.use_options("-M #{undersampling}")
          smote_dataset.apply_filter(subsample)
        else
          smote_dataset
        end
      end

      def self.replace_missing_values(dataset)
        puts 'replacing missing values…'
        filter = Weka::Filters::Unsupervised::Attribute::ReplaceMissingValues.new
        dataset.apply_filter(filter)
      end

      # Saves and returns a file index hash of structure
      # [file_name => full_path] for the given directory.
      def self.create_corpus_file_index!
        @config = Wikipedia::VandalismDetection.config
        revisions_directory = @config.training_corpus_revisions_directory

        raise RevisionsDirectoryNotConfiguredError unless revisions_directory

        print "\ncreating file index…"
        file_index = {}

        Dir.open revisions_directory do |part_directories|
          part_directories.each do |part_directory|
            Dir.open "#{revisions_directory}/#{part_directory}" do |contents|
              contents.each do |file|
                path = "#{revisions_directory}/#{part_directory}/#{file}"

                if File.file?(path) && (file =~ /\d+.txt/)
                  file_index[file] = path
                  print "\r processed #{file_index.count} files"
                end
              end
            end
          end
        end

        file = @config.training_output_index_file
        dirname = File.dirname(file)

        FileUtils.mkdir(dirname) unless Dir.exist?(dirname)

        written = File.open(file, 'w') { |f| f.write(file_index.to_yaml) }
        print "Index file saved to #{file}.\n" if written > 0

        file_index
      end

      # Loads arff files of given features and merge them into one arff file.
      # Returns the merged arff file.
      def self.merge_feature_arffs(features, output_directory)
        filter = Weka::Filters::Unsupervised::Attribute::Remove.new
        filter.use_options('-R last')
        merged_dataset = nil

        features.each do |feature|
          file_name = "#{feature.tr(' ', '_').downcase}.arff"
          arff_file = File.join(output_directory, file_name)

          feature_dataset = Weka::Core::Instances.from_arff(arff_file)
          puts "using #{File.basename(arff_file)}"

          if merged_dataset
            merged_dataset = merged_dataset
              .apply_filter(filter)
              .merge(feature_dataset)
          else
            merged_dataset = feature_dataset
          end
        end

        merged_dataset
      end

      # Creates a Wikipedia::Edit out of an annotation's edit id using files
      # form wikipedia-vandalism-detection.yml
      def self.create_edit_from(edit_id)
        @file_index ||= load_corpus_file_index
        edit_data = find_edits_data_for(edit_id)

        old_revision_id = edit_data['oldrevisionid'].to_i
        new_revision_id = edit_data['newrevisionid'].to_i

        editor = edit_data['editor']
        comment = edit_data['editcomment']
        new_timestamp = edit_data['edittime']
        page_id = edit_data['articleid']
        page_title = edit_data['articletitle']

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

        page = Page.new
        page.id = page_id
        page.title = page_title

        Edit.new(old_revision, new_revision, page: page)
      end

      # Gets or creates the corpus index file, which holds a hash of revision
      # files name and their path in the article revisions directory.
      def self.load_corpus_file_index
        index_file = @config.training_output_index_file

        if File.exist? index_file
          puts "\n(Using #{index_file})\n"
          YAML.load_file index_file
        else
          create_corpus_file_index!
        end
      end

      # Returns the line array of the edits.csv file with given edit id.
      def self.find_edits_data_for(edit_id)
        edits_file = Wikipedia::VandalismDetection.config.training_corpus_edits_file
        raise EditsFileNotConfiguredError unless edits_file

        @edits_file_content ||= File.read(edits_file)
        @edits_csv ||= CSV.parse(@edits_file_content, headers: true)

        edit_data = @edits_csv.find { |row| row['editid'] == edit_id }

        unless edit_data
          directory = File.basename(edits_file)
          raise "Edit data for edit id #{edit_id} not found in #{directory}."
        end

        edit_data
      end

      private_class_method :create_edit_from,
                           :merge_feature_arffs,
                           :find_edits_data_for,
                           :load_corpus_file_index,
                           :replace_missing_values
    end
  end
end

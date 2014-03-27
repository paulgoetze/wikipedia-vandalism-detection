require 'wikipedia/vandalism_detection/features/base'
require 'wikipedia/vandalism_detection/text'
require 'wikipedia/vandalism_detection/diff'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes average frequency of words inserted in the new revision
      # relative to the words in the old revision.
      class TermFrequency < FrequencyBase

        def calculate(edit)
          super

          old_text = edit.old_revision.text
          new_text = edit.new_revision.text

          begin
            inserted_terms_raw = Wikipedia::VandalismDetection::Diff.new(old_text, new_text).inserted_words.join("\n")
          rescue
            $stderr.puts "\nERROR while diffing: old #{edit.old_revision.id}, new: #{edit.new_revision.id}: \n#{e.message}"
            return 0.0
          end

          inserted_terms = Text.new(inserted_terms_raw).clean.gsub(/[^\w\s]/, '').split.uniq
          summed_frequencies = inserted_terms.reduce(0) { |count, term| count + frequency(new_text.clean, term) }

          (inserted_terms.count > 0) ? (summed_frequencies / inserted_terms.count) : 0.0
        end
      end
    end
  end
end
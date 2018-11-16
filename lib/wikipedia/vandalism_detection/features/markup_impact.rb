require 'wikipedia/vandalism_detection/features/base'
require 'wikipedia/vandalism_detection/word_lists/markup'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes the percentage by which the edit increases the
      # number of markup words in the text.
      class MarkupImpact < Base
        MARKUP_REGEX = /(#{WordLists::MARKUP.join('|')})/

        def calculate(edit)
          super

          old_text = edit.old_revision.text
          new_text = edit.new_revision.text

          old_markup_count = old_text.scan(MARKUP_REGEX).count.to_f
          new_markup_count = new_text.scan(MARKUP_REGEX).count.to_f

          if old_markup_count.zero? && new_markup_count.zero?
            0.5
          else
            old_markup_count / (old_markup_count + new_markup_count)
          end
        end
      end
    end
  end
end

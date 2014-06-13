require 'wikipedia/vandalism_detection/features/base'
require 'wikipedia/vandalism_detection/word_lists/markup'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes the percentage by which the edit increases the number of markup words in the text.
      class MarkupImpact < Base

        def calculate(edit)
          super

          old_text = edit.old_revision.text
          new_text = edit.new_revision.text
          regex = /(#{WordLists::MARKUP.join('|')})/

          old_markup_count = old_text.scan(regex).count.to_f
          new_markup_count = new_text.scan(regex).count.to_f

          no_terms_in_both = (old_markup_count == 0 && new_markup_count == 0)
          no_terms_in_both ? 0.5 : (old_markup_count / (old_markup_count + new_markup_count))
        end
      end
    end
  end
end
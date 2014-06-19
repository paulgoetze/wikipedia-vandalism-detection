require 'wikipedia/vandalism_detection/features/base'
require 'wikipedia/vandalism_detection/word_lists/emoticons'
require 'wikipedia/vandalism_detection/text'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature computes impact of emoticons words in the inserted text.
      class EmoticonsImpact < Base

        def calculate(edit)
          super

          old_text = edit.old_revision.text
          new_text = edit.new_revision.text

          regex = /(^|\W)(#{WordLists::EMOTICONS.join('|')}(?=\s|$|\Z))/

          old_count = old_text.scan(regex).flatten.reject { |c| c.size < 2 }.count.to_f
          new_count = new_text.scan(regex).flatten.reject { |c| c.size < 2 }.count.to_f

          no_terms_in_both = (old_count == 0 && new_count == 0)
          no_terms_in_both ? 0.5 : (old_count / (old_count + new_count))
        end
      end
    end
  end
end
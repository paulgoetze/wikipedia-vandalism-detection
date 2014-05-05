require 'wikipedia/vandalism_detection/word_lists/biased'
require 'wikipedia/vandalism_detection/word_lists/pronouns'
require 'wikipedia/vandalism_detection/word_lists/vulgarism'

module Wikipedia
  module VandalismDetection
    module WordLists

      # Returns an array of all wordlist words
      def self.all
        [*BIASED, *PRONOUNS, *VULGARISM]
      end

    end
  end
end
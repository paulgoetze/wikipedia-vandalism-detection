require 'wikipedia/vandalism_detection/word_lists/bad'
require 'wikipedia/vandalism_detection/word_lists/biased'
require 'wikipedia/vandalism_detection/word_lists/pronouns'
require 'wikipedia/vandalism_detection/word_lists/sex'
require 'wikipedia/vandalism_detection/word_lists/vulgarism'
require 'wikipedia/vandalism_detection/word_lists/markup'

module Wikipedia
  module VandalismDetection
    module WordLists
      # Returns an array of all wordlist words
      def self.all
        [*BAD, *BIASED, *PRONOUNS, *SEX, *VULGARISM].uniq!
      end
    end
  end
end

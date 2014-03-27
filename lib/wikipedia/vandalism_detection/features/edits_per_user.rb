require 'wikipedia/vandalism_detection/features/base'
require 'open-uri'
require 'nokogiri'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature calculates the number of submitted edits by the same editor (IP or ID) as the edit's editor.
      class EditsPerUser < Base

        def calculate(edit)
          super

          revision = edit.new_revision
          user = revision.anonymous_contributor? ? revision.contributor_ip : revision.contributor_id
          url = "http://en.wikipedia.org/w/api.php?action=query&format=xml&list=usercontribs&ucuser=#{user}&ucprop=ids"

          content = URI.parse(url).read
          puts "content: #{content}"
          items = Nokogiri::XML(content).to_a.to_s

        end
      end
    end
  end
end
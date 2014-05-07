require 'wikipedia/vandalism_detection/features/base'
require 'open-uri'
require 'nokogiri'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature calculates the number of submitted edits by the same editor (IP or ID) as the edit's editor.
      class EditsPerUser < Base

        # Returns the number of edits the edit's editor made in the same article.
        # Attention! This is pretty time consuming (~2sec) due to the url request.
        def calculate(edit)
          super

          revision = edit.new_revision
          xml = Wikipedia::api_request({ list: 'usercontribs', ucuser: revision.contributor, ucprop: 'ids' })
          page_item =  xml.xpath("//item[@revid='#{revision.id}']").first

          if page_item
            page_id = page_item.xpath("@pageid").text
            xml.xpath("//item[@pageid='#{page_id}']").count
          else
            0
          end
        end
      end
    end
  end
end
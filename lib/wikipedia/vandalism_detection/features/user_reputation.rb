require 'wikipedia/vandalism_detection/features/base'
require 'open-uri'
require 'nokogiri'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature calculates the average editor's reputation on the current article.
      class UserReputation < Base

        # Attention! This can be pretty time consuming (up to 2 sec) due to the url request.
        def calculate(edit)
          super

          revision = edit.new_revision
          page_id = edit.page_id || Wikipedia::api_request({ titles: edit.page_title }).xpath("//page/@pageid").first

          text = Wikipedia::wikitrust_request({ pageid: page_id, revid: revision.id })
          contributions = text.scan(/(\{\{#t:\d+,\d+,#{revision.contributor}\}\})/)
          # {{#t:trust,revision_id,UserName}}

          trust = 0.0

          unless contributions.empty?
            sum = contributions.reduce(0.0) do |sum, contribution|
              sum += contribution[0].split(',').first.split(':').last.to_f
            end

            trust = sum / contributions.count.to_f
          end

          trust
        end
      end
    end
  end
end
require 'wikipedia/vandalism_detection/features/base'
require 'open-uri'
require 'nokogiri'
require 'date'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature calculates the number of submitted edits by the same editor
      # (IP or ID) as the edit's editor.
      class EditsPerUser < Base
        # Returns the number of edits the edit's editor made in the same
        # article. Attention: This is pretty time consuming (~2sec) due to the
        # url request.
        def calculate(edit)
          super

          revision = edit.new_revision
          page = edit.page

          if page && page.id
            edits_count_from_page(edit)
          else
            edits_count_from_api_request(revision)
          end
        end

        protected

        def edits_count_from_page(edit)
          edit_revision = edit.new_revision

          edit.page.edits.reduce(0) do |count, page_edit|
            page_revision = page_edit.new_revision

            same_user = page_revision.contributor == edit_revision.contributor
            diff = time_diff(page_revision.timestamp, edit_revision.timestamp)

            count += 1 if same_user && diff.negative?
            count
          end
        end

        def edits_count_from_api_request(revision)
          params = {
            list: 'usercontribs',
            ucuser: revision.contributor,
            ucprop: 'ids|timestamp'
          }

          xml = Wikipedia.api_request(params)

          page_item = xml.xpath("//item[@revid='#{revision.id}']").first
          return 0 unless page_item

          page_id = page_item.xpath('@pageid').text

          # count only edits before current
          xml.xpath("//item[@pageid='#{page_id}']").reduce(0) do |count, item|
            time = item.attr('timestamp')
            count += 1 if time_diff(time, revision.timestamp).negative?
            count
          end
        end

        def time_diff(time1, time2)
          ((DateTime.parse(time1) - DateTime.parse(time2)) * 24 * 60 * 60).to_i
        end
      end
    end
  end
end

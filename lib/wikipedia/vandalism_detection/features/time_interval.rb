require 'wikipedia/vandalism_detection/features/base'
require 'date'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature computes the time interval in days between old and new
      # revision.
      class TimeInterval < Base
        def calculate(edit)
          super

          new_time = DateTime.parse(edit.new_revision.timestamp)

          if edit.old_revision.timestamp.blank?
            xml = Wikipedia.api_request(
              prop: 'revisions',
              rvprop: 'timestamp',
              revids: edit.old_revision.id
            )

            timestamp = xml.xpath('//rev/@timestamp').text
            return Features::MISSING_VALUE if timestamp.blank?

            old_time = DateTime.parse(timestamp)
          else
            old_time = DateTime.parse(edit.old_revision.timestamp)
          end

          (new_time - old_time).to_f.abs
        end
      end
    end
  end
end

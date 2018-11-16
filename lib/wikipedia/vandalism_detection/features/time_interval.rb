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
          old_timestamp = timestamp_for(edit.old_revision)

          return Features::MISSING_VALUE unless old_timestamp
          old_time = DateTime.parse(old_timestamp)

          (new_time - old_time).to_f.abs
        end

        private

        def timestamp_for(revision)
          return revision.timestamp if revision.timestamp.present?

          xml = Wikipedia.api_request(
            prop: 'revisions',
            rvprop: 'timestamp',
            revids: revision.id
          )

          xml.xpath('//rev/@timestamp').text.presence
        end
      end
    end
  end
end

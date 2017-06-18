require 'wikipedia/vandalism_detection/features/base'
require 'date'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature calculates the time of day of new revision edit as decimal
      # value .
      class TimeOfDay < Base
        def calculate(edit)
          super

          timestamp = edit.new_revision.timestamp
          time = DateTime.parse(timestamp)

          time.hour.to_f + time.min / 60.0 + time.sec / 360.0
        end
      end
    end
  end
end

require 'wikipedia/vandalism_detection/features/base'
require 'date'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature calculates the weekday of new revision edit as numeric value.
      # Monday => 1, Thuesday => 2, etc.
      class Weekday < Base

        def calculate(edit)
          super

          timestamp = edit.new_revision.timestamp
          DateTime.parse(timestamp).wday
        end
      end
    end
  end
end
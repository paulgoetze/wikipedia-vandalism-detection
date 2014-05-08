require 'wikipedia/vandalism_detection/features/contains_base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature returns whether the edit's comment includes 'copyedit'.
      class Copyedit < ContainsBase

        def calculate(edit)
          super

          contains(edit.new_revision.comment, ['copyedit', 'copy edit'])
        end
      end
    end
  end
end
require 'wikipedia/vandalism_detection/features/contains_base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature returns whether the edit's comment includes 'personal life'.
      class PersonalLife < ContainsBase

        def calculate(edit)
          super

          contains(edit.new_revision.comment, 'personal life')
        end
      end
    end
  end
end
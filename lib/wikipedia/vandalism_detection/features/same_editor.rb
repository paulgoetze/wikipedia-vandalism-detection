require_relative 'base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature describes whether the contributor of the new revision is the same as the editor
      # of the old revision.
      class SameEditor < Base

        def calculate(edit)
          super

          (edit.old_revision.contributor == edit.new_revision.contributor) ? 1 : 0
        end
      end
    end
  end
end
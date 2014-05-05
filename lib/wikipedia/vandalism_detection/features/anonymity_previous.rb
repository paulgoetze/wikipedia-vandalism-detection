require_relative 'base'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature describes whether the contributor of the old revision is an anonymous or
      # registered Wikipedia user.
      class AnonymityPrevious < Base

        def calculate(edit)
          super

          edit.old_revision.anonymous_contributor? ? 0 : 1
        end
      end
    end
  end
end
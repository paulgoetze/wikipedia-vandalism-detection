require_relative 'base'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature describes whether the contributor of the new revision is
      # an anonymous or registered Wikipedia user.
      class Anonymity < Base
        def calculate(edit)
          super

          edit.new_revision.anonymous_contributor? ? 0 : 1
        end
      end
    end
  end
end

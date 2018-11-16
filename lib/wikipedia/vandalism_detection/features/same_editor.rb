require_relative 'base'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature describes whether the contributor of the new revision is
      # the same as the editor of the old revision.
      class SameEditor < Base
        def calculate(edit)
          super

          old_revision = edit.old_revision

          if old_revision.contributor.blank?
            xml = Wikipedia.api_request(
              prop: 'revisions',
              rvprop: 'user',
              revids: old_revision.id
            )

            contributor = xml.xpath('//rev/@user').text
            return Features::MISSING_VALUE if contributor.blank?

            old_revision.contributor = contributor
          end

          old_revision.contributor == edit.new_revision.contributor ? 1 : 0
        end
      end
    end
  end
end

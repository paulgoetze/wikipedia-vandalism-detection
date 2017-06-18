require_relative 'base'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature describes whether the contributor of the old revision is
      # an anonymous or registered Wikipedia user.
      class AnonymityPrevious < Base
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

          old_revision.anonymous_contributor? ? 0 : 1
        end
      end
    end
  end
end

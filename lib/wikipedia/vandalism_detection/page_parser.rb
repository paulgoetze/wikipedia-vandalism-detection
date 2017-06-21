require 'nokogiri'
require_relative 'page'
require_relative 'revision'

module Wikipedia
  module VandalismDetection
    class PageParser
      # Parses an xml string and returns a Wikipedia::VandalismDetection::Page.
      def parse(xml)
        @page = Page.new
        document = Nokogiri::XML(xml, nil, 'UTF-8')

        @page.title = document.xpath('//page/title').inner_text
        @page.id = document.xpath('//page/id').inner_text

        build_revisions_from(document)

        @page
      end

      private

      def node_value(document, xpath)
        node = document.xpath(xpath.to_s)
        return if node.empty?

        node.inner_text
      end

      def node_text(document, xpath)
        value = node_value(document, xpath)
        return if value.blank?

        Text.new(value)
      end

      # Builds and saves the available revisions to the @page variable
      def build_revisions_from(document)
        elements = document.xpath('//revision')

        elements.each do |element|
          revision = Revision.new

          revision.id = node_value(element, :id)
          revision.timestamp = node_value(element, :timestamp)
          revision.comment = node_text(element, :comment)
          revision.text = node_text(element, :text)
          revision.sha1 = node_value(element, :sha1)
          revision.parent_id = node_value(element, :parentid)
          revision.contributor_username = node_value(element, 'contributor/username')

          contributor_id = node_value(element, 'contributor/id')
          contributor_ip = node_value(element, 'contributor/ip')

          revision.contributor = contributor_id if contributor_id
          revision.contributor = contributor_ip if contributor_ip

          @page.add_revision(revision)
        end
      end
    end
  end
end

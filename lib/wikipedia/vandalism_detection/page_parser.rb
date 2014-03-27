require 'nokogiri'
require_relative 'page'
require_relative 'revision'

module Wikipedia
  module VandalismDetection
    class PageParser

      # Parses an xml string and returns a Wikipedia::VandalismDetection::Page.
      def parse(xml)
        @page = Page.new
        document = Nokogiri::XML xml, nil, 'UTF-8'

        @page.title = document.xpath('//page/title').inner_text
        @page.id = document.xpath('//page/id').inner_text

        build_revisions_from document

        @page
      end

      private

      # Builds and saves the available revisions to the @page variable
      def build_revisions_from(document)
        elements = document.xpath('//revision')

        elements.each do |element|
          revision = Revision.new

          revision.id = element.xpath('id').inner_text
          revision.timestamp = element.xpath('timestamp').inner_text
          revision.comment = Text.new(element.xpath('comment').inner_text)
          revision.text = Text.new(element.xpath('text').inner_text)

          parent_id_node = element.xpath('parentid')
          contributor_id_node = element.xpath('contributor/id')
          contributor_ip_node = element.xpath('contributor/ip')
          contributor_username_node = element.xpath('contributor/username')

          revision.parent_id = parent_id_node.inner_text unless parent_id_node.empty?
          revision.contributor = contributor_id_node.inner_text unless contributor_id_node.empty?
          revision.contributor = contributor_ip_node.inner_text unless contributor_ip_node.empty?
          revision.contributor_username = contributor_username_node.inner_text unless contributor_username_node.empty?

          @page.add_revision(revision)
        end
      end
    end
  end
end
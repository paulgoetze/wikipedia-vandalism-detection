# encoding: utf-8

require 'nokogiri'
require 'wikipedia/vandalism_detection/revision'

module Wikipedia
  module VandalismDetection
    class RevisionParser

      # Parses an xml string and returns a Wikipedia::VandalismDetection::Revision.
      def parse(xml, options = {})
        document = Nokogiri::XML(xml, nil, 'UTF-8').xpath('//revision')

        revision = Revision.new

        properties = options[:only] || [:id, :parent_id, :timestamp, :contributor, :comment, :text, :sha1]

        revision.id = document.xpath('id').inner_text if properties.include?(:id)
        revision.timestamp = document.xpath('timestamp').inner_text if properties.include?(:timestamp)
        revision.comment = Text.new(document.xpath('comment').inner_text) if properties.include?(:comment)
        revision.text = Text.new(document.xpath('text').inner_text) if properties.include?(:text)
        revision.sha1 = document.xpath('sha1').inner_text if properties.include?(:sha1)

        if properties.include?(:contributor)
          contributor_id_node = document.xpath('contributor/id')
          contributor_ip_node = document.xpath('contributor/ip')
          contributor_username_node = document.xpath('contributor/username')

          revision.contributor = contributor_id_node.inner_text unless contributor_id_node.empty?
          revision.contributor = contributor_ip_node.inner_text unless contributor_ip_node.empty?
          revision.contributor_username = contributor_username_node.inner_text unless contributor_username_node.empty?
        end

        if properties.include?(:parent_id)
          parent_id_node = document.xpath('parentid')
          revision.parent_id = parent_id_node.inner_text unless parent_id_node.empty?
        end

        revision
      end
    end
  end
end
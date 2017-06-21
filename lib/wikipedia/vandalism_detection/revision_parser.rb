# encoding: utf-8

require 'nokogiri'
require 'wikipedia/vandalism_detection/revision'

module Wikipedia
  module VandalismDetection
    class RevisionParser
      DEFAULT_PROPERTIES = %i[
        id
        parent_id
        timestamp
        contributor
        comment
        text
        sha1
      ].freeze

      # Parses an xml string and returns a Revision.
      def parse(xml, options = {})
        document = Nokogiri::XML(xml, nil, 'UTF-8').xpath('//revision')
        revision = Revision.new

        properties = options[:only] || DEFAULT_PROPERTIES

        revision.id        = node_value(document, properties, :id)
        revision.timestamp = node_value(document, properties, :timestamp)
        revision.comment   = node_text(document, properties, :comment)
        revision.text      = node_text(document, properties, :text)
        revision.sha1      = node_value(document, properties, :sha1)

        if properties.include?(:contributor)
          revision.contributor = node_presence(document, 'contributor/id')
          revision.contributor = node_presence(document, 'contributor/ip')
          revision.contributor_username = node_presence(document, 'contributor/username')
        end

        if properties.include?(:parent_id)
          revision.parent_id = node_presence(document, 'parentid')
        end

        revision
      end

      private

      def node_value(document, properties, attribute)
        return unless properties.include?(attribute)
        node_presence(document, attribute)
      end

      def node_text(document, properties, attribute)
        value = node_value(document, properties, attribute)
        return if value.blank?

        Text.new(value)
      end

      def node_presence(document, xpath)
        node = document.xpath(xpath.to_s)
        return if node.empty?

        node.inner_text
      end
    end
  end
end

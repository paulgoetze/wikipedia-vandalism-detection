require_relative 'text'

module Wikipedia
  module VandalismDetection
    class Revision

      START_TAG = '<revision>'.freeze
      END_TAG = '</revision>'.freeze
      REDIRECT_PATTERN = /#REDIRECT\s+\[\[.*?\]\]/

      attr_accessor :id,
                    :parent_id,
                    :timestamp,
                    :comment,
                    :text,
                    :contributor_username,
                    :sha1

      attr_reader :contributor_id,
                  :contributor_ip

      def initialize
        @text = Text.new
        @comment = Text.new
      end

      def contributor=(contributor)
        if ip_v4? contributor
          @contributor_ip = contributor
        else
          @contributor_id = contributor
        end
      end

      def contributor
        @contributor_id || @contributor_ip
      end

      def anonymous_contributor?
        !@contributor_ip.nil?
      end

      def redirect?
        # remove invalid utf-8 byte sequences
        @text.encode!('UTF-16', 'UTF-8', invalid: :replace, replace: '')
        @text.encode!('UTF-8', 'UTF-16')

        !!(@text =~ REDIRECT_PATTERN)
      end

      private

      # Returns whether the given value is an IPv4.
      def ip_v4?(value)
        !!value.to_s.match(/(\d+)\.(\d+)\.(\d+)\.(\d+)/)
      end

    end
  end
end
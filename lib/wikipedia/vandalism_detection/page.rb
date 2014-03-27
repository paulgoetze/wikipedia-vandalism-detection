require 'nokogiri'
require_relative 'edit'

module Wikipedia
  module VandalismDetection

    # Represents a full wikipedia page history.
    class Page

      START_TAG = '<page>'.freeze
      END_TAG = '</page>'.freeze

      attr_accessor :id, :title
      attr_reader :revisions

      def initialize
        @revisions = {}
        @edits = []
      end

      def add_revision(revision)
        unless revision.redirect?
          @revisions[revision.id] = revision
          @revision_added = true
        end
      end

      def edits
        if @revision_added
         create_edits_from @revisions
        else
         @edits
        end
      end

      private

      def create_edits_from(revisions)
        @revision_added = false
        @edits = []

        revisions.each do |id, new_revision|
          old_revision = revisions[new_revision.parent_id]
          @edits.push Edit.new(old_revision, new_revision) unless old_revision.nil?
        end

        @edits
      end
    end
  end
end
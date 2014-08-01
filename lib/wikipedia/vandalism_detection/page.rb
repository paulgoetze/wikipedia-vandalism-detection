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
        @revision_added = false
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

      # Returns the reverted edits by comparing the text's sha1 hashes of multiple revisions.
      # If the next but one revision has the same sha1 hash as a base revision, the in-between revision is reverted.
      # Then the edit has the base revision as old revision and the reverted as new revision.
      def reverted_edits
        if @revision_added
          @reverted_edits = @revisions.map do |current_id, current_revision|
            mid_revision_select = @revisions.select { |_, value| value.parent_id == current_id }.first

            next unless mid_revision_select

            mid_revision = mid_revision_select[1]
            target_revision_select = @revisions.select { |_, value| value.parent_id == mid_revision.id }.first

            next unless target_revision_select

            target_revision = target_revision_select[1]

            base_sha1 = current_revision.sha1
            target_sha1 = target_revision.sha1

            if base_sha1 == target_sha1
              Edit.new(current_revision, mid_revision)
            end
          end
        end

        @reverted_edits.compact!
      end

      private

      def create_edits_from(revisions)
        @revision_added = false
        @edits = []

        revisions.each do |id, new_revision|
          old_revision = revisions[new_revision.parent_id]
          @edits.push Edit.new(old_revision, new_revision) unless old_revision.nil?
        end

        @edits.each { |edit| edit.instance_variable_set(:@page, self) }
        @edits
      end
    end
  end
end
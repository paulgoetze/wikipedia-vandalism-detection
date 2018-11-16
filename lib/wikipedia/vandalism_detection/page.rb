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
        @update_edits = false
        @update_reverted_edits = false
      end

      def add_revision(revision)
        @revisions[revision.id] = revision

        @update_edits = true
        @update_reverted_edits = true
      end

      def edits
        @edits = create_edits_from @revisions if @update_edits
        @edits
      end

      def reverted_edits
        if @update_reverted_edits
          @reverted_edits = create_reverted_edits_from @revisions
        end

        @reverted_edits
      end

      private

      def create_edits_from(revisions)
        @update_edits = false
        edits = []

        revisions.each do |_, new_revision|
          old_revision = revisions[new_revision.parent_id]
          edits << Edit.new(old_revision, new_revision) unless old_revision.nil?
        end

        edits.each { |edit| edit.instance_variable_set(:@page, self) }
        edits
      end

      # Returns the reverted edits by comparing the text's sha1 hashes of
      # multiple revisions.
      # If the next but one revision has the same sha1 hash as a base revision
      # and the base revision has another hash than the one before, the
      # in-between revision is reverted.
      # The resulting edit holds the base revision as old revision and the
      # reverted as new revision.
      def create_reverted_edits_from(revisions)
        @update_reverted_edits = false
        edits = []

        revisions.each do |current_id, first_revision|
          second_revision_select = revisions
            .select { |_, value| value.parent_id == current_id }
            .first

          next unless second_revision_select

          second_revision = second_revision_select[1]

          third_revision_select = revisions
            .select { |_, value| value.parent_id == second_revision.id }
            .first

          next unless third_revision_select

          first_sha1 = first_revision.sha1
          second_sha1 = second_revision.sha1
          third_sha1 = third_revision_select[1].sha1

          previous_revision_select = revisions
            .select { |_, value| value.id == first_revision.parent_id }
            .first

          previous_sha1 = previous_revision_select && previous_revision_select[1].sha1

          if (first_sha1 == third_sha1) && (second_sha1 != previous_sha1)
            edits << Edit.new(first_revision, second_revision)
          end
        end

        edits
      end
    end
  end
end

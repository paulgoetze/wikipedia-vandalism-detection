module Wikipedia
  module VandalismDetection

    require 'java'
    require 'java/diffutils-1.3.0.jar'

    java_import 'difflib.DiffUtils'

    class Diff

      def initialize(original, current)
        @original = original.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
        @current = current.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')

        @patch = DiffUtils.diff @original.split, @current.split
      end

      def inserted_words
        @patch.deltas.map {|delta| delta.revised.lines }.flatten
      end

      def removed_words
        @patch.deltas.map {|delta| delta.original.lines }.flatten
      end
    end
  end
end
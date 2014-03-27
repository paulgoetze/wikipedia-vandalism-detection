require 'wikipedia/vandalism_detection/features/base'
require 'zlib'
require 'wikipedia/vandalism_detection/diff'

module Wikipedia
  module VandalismDetection
    module Features

      # This feature describes compressibility ratio of compressed and uncompressed inserted text.
      class Compressibility < Base

        # Claculates the compressibility ratio of the inserted text.
        # Values above 0.5 are higher compressed and therefor can stand for nonsense text as:
        # 'AAAAAAAAAAAAAAAAAAAhhhhhhhhhhhhhhhh!' etc.
        def calculate(edit)
          super

          old_text = edit.old_revision.text
          new_text = edit.new_revision.text

          inserted_text = Wikipedia::VandalismDetection::Diff.new(old_text, new_text).inserted_words.join(' ')
          uncompressed_size = inserted_text.bytesize.to_f
          compressed_size = Zlib::Deflate.deflate(inserted_text).bytesize.to_f

          new_text.empty? ? 0.5 : (uncompressed_size / ( compressed_size + uncompressed_size))
        end
      end
    end
  end
end
require 'wikipedia/vandalism_detection/features/base'
require 'zlib'
require 'wikipedia/vandalism_detection/diff'

module Wikipedia
  module VandalismDetection
    module Features
      # This feature describes compressibility ratio of compressed and
      # uncompressed inserted text.
      class Compressibility < Base
        # Calculates the compressibility ratio of the inserted text.
        # Values above 0.5 are higher compressed and therefor can stand for
        # nonsense text as:
        # 'AAAAAAAAAAAAAAAAAAAhhhhhhhhhhhhhhhh!' etc.
        def calculate(edit)
          super

          inserted_text = edit.inserted_text
          uncompressed_size = inserted_text.bytesize.to_f
          compressed_size = Zlib::Deflate.deflate(inserted_text).bytesize.to_f

          if inserted_text.empty?
            0.5
          else
            uncompressed_size / (compressed_size + uncompressed_size)
          end
        end
      end
    end
  end
end

require 'ruby-band'
require 'wikipedia/vandalism_detection/configuration'

module Wikipedia
  module VandalismDetection

    class Instances

      VANDALISM_CLASS_INDEX = 0
      REGULAR_CLASS_INDEX = 1
      VANDALISM = "vandalism"
      REGULAR = "regular"

      OLD_REVISION_ID = 'oldrevisionid'
      NEW_REVISION_ID = 'newrevisionid'

      CLASSES = { VANDALISM_CLASS_INDEX => VANDALISM , REGULAR_CLASS_INDEX => REGULAR }

      # Returns an empty instances dataset of type Java::WekaCore::Instances::Base.
      # This dataset is used for feature computation and classification for Wikipedia vandalism detection
      # while training.
      #
      # @example
      #   datset = Wikipedia::VandalismDetection::Instances.empty
      #   => #<Java::WekaCore::Instances::Base:0xf0f9a00
      #      @positions=[
      #        #<Java::WekaCore::Attribute:0x17207a76>,
      #        #<Java::WekaCore::Attribute:0x5547e4d6>,
      #        #<Java::WekaCore::Attribute:0x6300c957>,
      #        ...,
      #        #<Java::WekaCore::Attribute:0x5a74fae4>]>
      def self.empty
        features = Wikipedia::VandalismDetection.configuration.features

        dataset_classes = Array.new
        dataset_classes[VANDALISM_CLASS_INDEX] = VANDALISM
        dataset_classes[REGULAR_CLASS_INDEX] = REGULAR

        dataset = Core::Type::Instances::Base.new do
          features.each do |name|
            numeric :"#{name.gsub(' ', '_')}"
          end

          nominal :class, dataset_classes
        end

        dataset.class_index = features.count
        dataset
      end

      # Returns an empty instances dataset of type Java::WekaCore::Instances::Base.
      # This dataset is used for feature computation and classification for Wikipedia vandalism detection
      # while testing.
      #
      # @example
      #   datset = Wikipedia::VandalismDetection::Instances.empty_for_test
      #   => #<Java::WekaCore::Instances::Base:0xf0f9a00
      #      @positions=[
      #        #<Java::WekaCore::Attribute:0x17207a76>,
      #        #<Java::WekaCore::Attribute:0x5547e4d6>,
      #        #<Java::WekaCore::Attribute:0x6300c957>,
      #        ...,
      #        #<Java::WekaCore::Attribute:0x5a74fae4>]>
      def self.empty_for_test
        features = Wikipedia::VandalismDetection.configuration.features

        dataset = Core::Type::Instances::Base.new do
          features.each do |name|
            numeric :"#{name.gsub(' ', '_')}"
          end

          numeric OLD_REVISION_ID.to_sym
          numeric NEW_REVISION_ID.to_sym
        end

        dataset
      end
    end
  end
end
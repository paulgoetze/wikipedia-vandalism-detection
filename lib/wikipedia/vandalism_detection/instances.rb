require 'weka'
require 'wikipedia/vandalism_detection/configuration'
require 'weka/classifiers/meta/one_class_classifier'

module Wikipedia
  module VandalismDetection

    class Instances

      REGULAR_CLASS_INDEX = 0
      VANDALISM_CLASS_INDEX = 1
      NOT_KNOWN_INDEX = 2

      CLASS = 'class'
      VANDALISM = 'vandalism'
      REGULAR = 'regular'
      NOT_KNOWN = '?'
      OUTLIER = Weka::Classifiers::Meta::OneClassClassifier::OUTLIER_LABEL

      VANDALISM_SHORT= 'V'
      REGULAR_SHORT = 'R'

      OLD_REVISION_ID = 'oldrevisionid'
      NEW_REVISION_ID = 'newrevisionid'


      CLASSES = {
          REGULAR_CLASS_INDEX => REGULAR,
          VANDALISM_CLASS_INDEX => VANDALISM,
          NOT_KNOWN_INDEX => NOT_KNOWN
      }

      CLASSES_SHORT = {
          REGULAR_CLASS_INDEX => REGULAR_SHORT,
          VANDALISM_CLASS_INDEX => VANDALISM_SHORT,
          NOT_KNOWN_INDEX => NOT_KNOWN
      }

      class << self
        # Returns an empty instances dataset of type Java::WekaCore::Instances.
        # This dataset is used for feature computation and classification for
        # Wikipedia vandalism detection while training.
        #
        # @example
        #   datset = Wikipedia::VandalismDetection::Instances.empty
        #   => #<Java::WekaCore::Instances:0xf0f9a00
        #      @positions=[
        #        #<Java::WekaCore::Attribute:0x17207a76>,
        #        #<Java::WekaCore::Attribute:0x5547e4d6>,
        #        #<Java::WekaCore::Attribute:0x6300c957>,
        #        ...,
        #        #<Java::WekaCore::Attribute:0x5a74fae4>]>
        def empty
          features = Wikipedia::VandalismDetection.configuration.features
          classes = dataset_classes

          dataset = Weka::Core::Instances.new.with_attributes do
            features.each do |name|
              numeric name.tr(' ', '_')
            end

            nominal :class, values: classes, class_attribute: true
          end

          dataset
        end

        # Returns an empty instances dataset of type Java::WekaCore::Instances.
        # This dataset is used for feature computation and classification for
        # Wikipedia vandalism detection while training.
        #
        # @example
        #   datset = Wikipedia::VandalismDetection::Instances.empty
        #   => #<Java::WekaCore::Instances:0xf0f9a00
        #      @positions=[
        #        #<Java::WekaCore::Attribute:0x17207a76>
        def empty_for_feature(name)
          classes = dataset_classes

          Weka::Core::Instances.new.with_attributes do
            numeric name.gsub(' ', '_')
            nominal :class, values: classes, class_attribute: true
          end
        end

        # Returns an empty instances dataset of type Java::WekaCore::Instances.
        # This dataset is used for feature computation and classification for
        # Wikipedia vandalism detection while testing.
        #
        # @example
        #   datset = Wikipedia::VandalismDetection::Instances.empty_for_test
        #   => #<Java::WekaCore::Instances:0xf0f9a00
        #      @positions=[
        #        #<Java::WekaCore::Attribute:0x17207a76>]>
        def empty_for_test_feature(name)
          Weka::Core::Instances.new.with_attributes do
            numeric name.gsub(' ', '_')
            numeric OLD_REVISION_ID
            numeric NEW_REVISION_ID
          end
        end

        # Returns an empty instances dataset of type Java::WekaCore::Instances::Base.
        # This dataset is used for creating the ground truth classification.
        def empty_for_test_class
          classes = dataset_classes

          Weka::Core::Instances.new.with_attributes do
            nominal :class, values: classes
          end
        end

        private

        def dataset_classes
          classes = Array.new
          classes[VANDALISM_CLASS_INDEX] = VANDALISM
          classes[REGULAR_CLASS_INDEX]   = REGULAR
          classes
        end
      end
    end

  end
end

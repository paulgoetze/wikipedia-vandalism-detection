require 'active_support/core_ext/module'
require 'ruby-band'
require 'ruby-band/weka/classifiers/class_builder'

module Weka
  module Classifiers
    module Meta
      include ClassBuilder

      require 'java'
      require 'java/oneClassClassifier.jar'

      # One class classifier by C. Hempstalk (cite: http://dl.acm.org/citation.cfm?id=1431987)
      # Jar can be downloaded at: http://sourceforge.net/projects/weka/files/weka-packages/oneClassClassifier1.0.4.zip
      build_classes :OneClassClassifier

      class OneClassClassifier

        def self.type
          "Meta::OneClassClassifier"
        end
      end
    end
  end
end
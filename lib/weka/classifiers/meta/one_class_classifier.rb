require 'weka'
require 'weka/class_builder'

module Weka
  module Classifiers
    module Meta
      require 'java/oneClassClassifier.jar'
      include ClassBuilder

      # One class classifier by C. Hempstalk (cite: http://dl.acm.org/citation.cfm?id=1431987)
      # Jar can be downloaded at: http://sourceforge.net/projects/weka/files/weka-packages/oneClassClassifier1.0.4.zip
      build_class :OneClassClassifier

      class OneClassClassifier
        def self.type
          'Meta::OneClassClassifier'
        end
      end
    end
  end
end

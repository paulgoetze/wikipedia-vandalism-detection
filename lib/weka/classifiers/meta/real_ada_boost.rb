require 'ruby-band'
require 'ruby-band/weka/classifiers/class_builder'

module Weka
  module Classifiers
    module Meta
      include ClassBuilder

      require 'java'
      require 'java/realAdaBoost.jar'

      # Real ada boost classifier, see: http://www.stanford.edu/~hastie/Papers/AdditiveLogisticRegression/alr.pdf
      # Jar can be downloaded at: http://prdownloads.sourceforge.net/weka/realAdaBoost1.0.1.zip?download
      build_classes :RealAdaBoost
    end
  end
end
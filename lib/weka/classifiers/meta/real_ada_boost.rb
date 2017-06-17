require 'weka'
require 'weka/class_builder'

module Weka
  module Classifiers
    module Meta
      require 'java/realAdaBoost.jar'
      include ClassBuilder


      # Real ada boost classifier, see: http://www.stanford.edu/~hastie/Papers/AdditiveLogisticRegression/alr.pdf
      # Jar can be downloaded at: http://prdownloads.sourceforge.net/weka/realAdaBoost1.0.1.zip?download
      build_class :RealAdaBoost
    end
  end
end

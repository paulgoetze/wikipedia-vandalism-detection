require 'ruby-band'
require 'ruby-band/weka/classifiers/class_builder'

module Weka
  module Classifiers
    module Functions
      require 'java'
      require 'java/libsvm.jar'
      require 'java/LibSVM.jar'

      include ClassBuilder
      build_classes :LibSVM
    end
  end
end
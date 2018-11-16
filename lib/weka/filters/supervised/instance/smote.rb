require 'weka'
require 'weka/class_builder'

module Weka
  module Filters
    module Supervised
      module Instance
        require 'java/SMOTE.jar'
        include ClassBuilder

        build_class :SMOTE
      end
    end
  end
end

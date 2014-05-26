require 'ruby-band'
require 'ruby-band/weka/filters/supervised/utils'

module Weka
  module Filters
    module Supervised
      module Instance

        require 'java'
        require 'java/SMOTE.jar'

        java_import "weka.filters.supervised.instance.SMOTE"

        class SMOTE
          include Weka::Filters::Supervised::Utils
        end

        Weka::Filters::Supervised::Instance::SMOTE.__persistent__ = true
      end
    end
  end
end
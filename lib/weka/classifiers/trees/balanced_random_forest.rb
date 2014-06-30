require 'ruby-band'
require 'ruby-band/weka/classifiers/class_builder'

module Weka
  module Classifiers
    module Trees
      include ClassBuilder

      require 'java'
      require 'java/balancedRandomForest.jar'

      # balanced RandomForest classifier,
      # Modified from https://github.com/jdurbin/durbinlib/blob/master/src/durbin/weka/BalancedRandomForest.java
      # and https://github.com/jdurbin/durbinlib/blob/master/src/durbin/weka/BalancedRandomTree.java
      build_classes :BalancedRandomForest
    end
  end
end
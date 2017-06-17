require 'weka'
require 'weka/class_builder'

module Weka
  module Classifiers
    module Trees
      require 'java/balancedRandomForest.jar'
      include ClassBuilder


      # balanced RandomForest classifier,
      # Modified from https://github.com/jdurbin/durbinlib/blob/master/src/durbin/weka/BalancedRandomForest.java
      # and https://github.com/jdurbin/durbinlib/blob/master/src/durbin/weka/BalancedRandomTree.java
      build_class :BalancedRandomForest
    end
  end
end

require 'wikipedia/vandalism_detection/version'
require 'wikipedia/vandalism_detection/configuration'
require 'wikipedia/vandalism_detection/exceptions'

require 'wikipedia/vandalism_detection/text'
require 'wikipedia/vandalism_detection/revision'
require 'wikipedia/vandalism_detection/edit'
require 'wikipedia/vandalism_detection/page'
require 'wikipedia/vandalism_detection/page_parser'

require 'wikipedia/vandalism_detection/word_lists'
require 'wikipedia/vandalism_detection/diff'
require 'wikipedia/vandalism_detection/wikitext_extractor'
require 'wikipedia/vandalism_detection/features'
require 'wikipedia/vandalism_detection/feature_calculator'

require 'wikipedia/vandalism_detection/instances'
require 'wikipedia/vandalism_detection/training_dataset'
require 'wikipedia/vandalism_detection/test_dataset'
require 'wikipedia/vandalism_detection/classifier'
require 'wikipedia/vandalism_detection/evaluator'

require 'weka/classifiers/meta/one_class_classifier'
require 'weka/classifiers/functions/lib_svm'
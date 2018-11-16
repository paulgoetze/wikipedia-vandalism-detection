require 'rspec'
require 'factory_bot'
require 'fileutils'

def require_files_from(paths = [])
  paths.each do |path|
    Dir[File.join(File.expand_path("#{path}*.rb", __FILE__))].each do |file|
      require file
    end
  end
end

RSpec.configure do |config|
  base_path = '../../lib/wikipedia/vandalism_detection'
  lib_file = File.expand_path(base_path, __FILE__)
  require lib_file

  dirs = %w[../factories/**/ ../support/**/]
  require_files_from dirs

  config.include FileReading
  config.include TestConfiguration
  config.include FactoryBot::Syntax::Methods

  config.after(:suite) do
    test_build_dir = File.expand_path('../resources/build', __FILE__)
    FileUtils.remove_dir(test_build_dir) if Dir.exist?(test_build_dir)
  end

  Classifier      = Wikipedia::VandalismDetection::Classifier
  Edit            = Wikipedia::VandalismDetection::Edit
  Evaluator       = Wikipedia::VandalismDetection::Evaluator
  Features        = Wikipedia::VandalismDetection::Features
  Instances       = Wikipedia::VandalismDetection::Instances
  Page            = Wikipedia::VandalismDetection::Page
  Text            = Wikipedia::VandalismDetection::Text
  TrainingDataset = Wikipedia::VandalismDetection::TrainingDataset
end

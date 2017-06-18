require 'rspec'
require 'factory_girl'

def require_files_from(paths = [])
  paths.each do |path|
    Dir[File.join(File.expand_path("#{path}*.rb", __FILE__))].each do |file|
      require file
    end
  end
end

RSpec.configure do |config|
  lib_file = File.expand_path('../../lib/wikipedia/vandalism_detection', __FILE__)
  require lib_file

  dirs = ["../factories/**/", "../support/**/"]
  require_files_from dirs

  config.include FileReading
  config.include TestConfiguration
  config.include FactoryGirl::Syntax::Methods

  Features = Wikipedia::VandalismDetection::Features
  Text = Wikipedia::VandalismDetection::Text
end

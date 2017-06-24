require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new

task :default
task test: :spec

desc 'Start an irb session with the gem loaded'
task :irb do
  sh 'irb -I ./lib -r wikipedia/vandalism_detection'
end

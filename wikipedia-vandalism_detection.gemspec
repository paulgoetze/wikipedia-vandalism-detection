# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wikipedia/vandalism_detection/version'

Gem::Specification.new do |spec|
  spec.name          = 'wikipedia-vandalism_detection'
  spec.version       = Wikipedia::VandalismDetection::VERSION
  spec.authors       = ['Paul Götze']
  spec.email         = ['paul.christoph.goetze@gmail.com']
  spec.summary       = %q{Wikipedia vandalism detection with JRuby.}
  spec.description   = %q{Wikipedia vandalism detection with JRuby.}
  spec.homepage      = ''
  spec.license       = 'GPL v3'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.extensions    = ['Rakefile']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.platform               = 'java'
  spec.required_ruby_version  = '~> 2.0'

  spec.add_runtime_dependency 'weka', '~> 0.5'
  spec.add_runtime_dependency 'nokogiri', '~> 1.8'
  spec.add_runtime_dependency 'activesupport', '>= 4.0'
  spec.add_runtime_dependency 'hotwater', '~> 0.1.2'
  spec.add_runtime_dependency 'parallel', '~> 1.11'


  spec.add_development_dependency 'bundler', '>= 1.5'
  spec.add_development_dependency 'rake', '>= 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'factory_girl', '~> 4.8'
end

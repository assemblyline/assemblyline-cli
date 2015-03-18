# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'assemblyline/cli/version'

Gem::Specification.new do |spec|
  spec.name          = "assemblyline-cli"
  spec.version       = Assemblyline::CLI_VERSION
  spec.authors       = ["Ed Robinson"]
  spec.email         = ["ed@reevoo.com"]
  spec.summary       = %q{A super-lightweight wrapper to start assemblyline tasks}
  spec.homepage      = "http://github.com/assemblyline"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 0.19"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end

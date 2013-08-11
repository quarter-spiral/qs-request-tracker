# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'qs/request/tracker/version'

Gem::Specification.new do |spec|
  spec.name          = "qs-request-tracker"
  spec.version       = Qs::Request::Tracker::VERSION
  spec.authors       = ["Thorben Schröder"]
  spec.email         = ["stillepost@gmail.com"]
  spec.description   = %q{Manages a Request-Id for each HTTP request}
  spec.summary       = %q{Manages a Request-Id for each HTTP request}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "faraday"
  spec.add_development_dependency "service-client", ">= 0.0.14"
  spec.add_development_dependency "sinatra"
  spec.add_development_dependency "rack-client"
  spec.add_development_dependency "rack-test"

  spec.add_dependency 'uuid'
end

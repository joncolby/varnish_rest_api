# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'varnish_rest_api/version'

Gem::Specification.new do |spec|
  spec.name          = "varnish_rest_api"
  spec.version       = VarnishRestApi::VERSION
  spec.authors       = ["Jonathan Colby"]
  spec.email         = ["jcolby@team.mobile.de"]
  spec.summary       = %q{A sinatra rest api for varnish.}
  spec.description   = %q{A restful http api for setting backend health, banning cache objects and getting status information. Executes varnishadm via http rest calls.}
  spec.homepage      = "http://rubygems.org/gems/varnish_rest_api"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.files         << ["bin/varnishrestapi.rb"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
  
  spec.add_dependency "sinatra"
  spec.add_dependency "zk"
  spec.add_dependency "zookeeper"
  spec.add_dependency "json"
  
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end

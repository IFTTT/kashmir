# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kashmir/version'

Gem::Specification.new do |spec|
  spec.name          = "kashmir"
  spec.version       = Kashmir::VERSION
  spec.authors       = ["IFTTT", "Netto Farah"]
  spec.email         = ["ops@ifttt.com", "nettofarah@gmail.com"]
  spec.summary       = %q{Kashmir is a DSL for quickly defining contracts to decorate your models.}
  spec.description   = %q{
    Kashmir helps you easily define decorators/representers/presenters for ruby objects.
    Optionally, Kashmir will also cache these views for faster lookups.
  }
  spec.homepage      = "http://ifttt.github.io/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "minitest-around", "~> 0.3"
  spec.add_development_dependency "mocha", "~> 1.1"
  spec.add_development_dependency "sqlite3", "1.3.10"

  spec.add_development_dependency "activerecord", "~> 4.2"
end

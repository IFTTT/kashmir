# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kashmir/version'

Gem::Specification.new do |spec|
  spec.name          = "kashmir"
  spec.version       = Kashmir::VERSION
  spec.authors       = ["Netto Farah"]
  spec.email         = ["nettofarah@gmail.com"]
  spec.summary       = %q{Kashmir is a DSL for quickly defining contracts to decorate your models.}
  spec.description   = %q{
    Kashmir helps you easily define decorators/representers/presenters for ruby objects.
    Optionally, Kashmir will also cache these views for faster lookups.
  }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activerecord"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "minitest-ansi"
  spec.add_development_dependency "sqlite3"
end

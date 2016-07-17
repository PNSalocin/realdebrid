# frozen_string_literal: true
# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'realdebrid'

Gem::Specification.new do |spec|
  spec.name          = "realdebrid"
  spec.version       = RealDebrid::VERSION
  spec.authors       = ["Nicolas MERELLI"]
  spec.email         = ["nicolas.merelli@gmail.com"]

  spec.summary       = "Permet un dialogue plus aisé avec real-debrid"
  spec.description   = "Permet un dialogue plus aisé avec real-debrid"
  spec.homepage      = "https://github.com/PNSalocin/realdebrid"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split("\n").reject { |f| f.match(%r{^(|spec|)/}) }
  spec.test_files    = `git ls-files -- spec/*`.split("\n")
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "yard"
end

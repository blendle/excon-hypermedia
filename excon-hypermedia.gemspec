# frozen_string_literal: true
# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'excon/hypermedia/version'

Gem::Specification.new do |spec|
  spec.name          = 'excon-hypermedia'
  spec.version       = Excon::Hypermedia::VERSION
  spec.authors       = %w(Jean Mertz)
  spec.email         = %w(jean@mertz.fm)

  spec.summary       = 'Excon, with Hypermedia traversing baked in.'
  spec.description   = 'Excon, with Hypermedia traversing baked in.'
  spec.homepage      = 'https://github.com/JeanMertz/excon-hypermedia'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0")
  spec.require_paths = %w(lib)

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rubocop', '~> 0.40'
  spec.add_development_dependency 'pry', '~> 0.10'

  spec.add_dependency 'excon', '~> 0.49'
  spec.add_dependency 'excon-addressable', '~> 0.1'
end

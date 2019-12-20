# frozen_string_literal: true

# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deep_health_check/version'

Gem::Specification.new do |spec|
  spec.name          = 'deep_health_check'
  spec.version       = DeepHealthCheck::VERSION
  spec.authors       = ['Al-waleed shihadeh']
  spec.email         = ['shihadeh.dev@gmail.com']

  spec.summary       = 'Provides a health check API endpoint'
  spec.description   = 'Provides a health check API endpoint'
  spec.homepage      = 'https://github.com/wshihadeh/deep_health_check'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'net-telnet'
  spec.add_dependency 'faraday'
  spec.add_dependency 'faraday_middleware'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rack-test', '~> 0.8.2'
  spec.add_development_dependency 'rspec', '~> 3.5.0'
  spec.add_development_dependency 'rubocop', '0.48.0'
end

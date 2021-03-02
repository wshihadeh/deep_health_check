# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deep_health_check/version'

Gem::Specification.new do |spec|
  spec.name          = 'deep_health_check'
  spec.version       = DeepHealthCheck::VERSION
  spec.authors       = ['Al-waleed shihadeh']
  spec.email         = ['shihadeh.dev@gmail.com']

  spec.summary       = 'Provides a health check API endpoint'
  spec.description   = 'Provides a health check API endpoint for rack apps'
  spec.homepage      = 'https://github.com/wshihadeh/deep_health_check'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'faraday', '~> 1.0'
  spec.add_dependency 'net-telnet', '~> 0.2'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'codecov', '~> 0'
  spec.add_development_dependency 'rack-test', '~> 1.1', '>= 1.1.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9', '>= 3.9.0'
  spec.add_development_dependency 'rubocop', '1.11.0'
end

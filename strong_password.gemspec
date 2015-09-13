# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'strong_password/version'

Gem::Specification.new do |spec|
  spec.name          = 'strong_password'
  spec.version       = StrongPassword::VERSION
  spec.authors       = ['Brian McManus']
  spec.email         = ['bdmac97@gmail.com']
  spec.description   = 'Entropy-based password strength checking for Ruby and ActiveModel'
  spec.summary       = 'StrongPassword adds a class to check password strength and a validator for ActiveModel'
  spec.homepage      = 'https://github.com/bdmac/strong_password'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 2.12'
  spec.add_development_dependency 'pry'
end

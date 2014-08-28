# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sms-club/version'

Gem::Specification.new do |spec|
  spec.name          = 'sms-club'
  spec.version       = Sms::Club::VERSION
  spec.authors       = ['Pavel Dotsulenko']
  spec.email         = ['paul@live.ru']
  spec.summary       = 'Client for http://smsclub.mobi/ SMS gate'
  spec.description   = 'Client for http://smsclub.mobi/ SMS gate. Allows you to send and retrieve status of sent SMS via XML API. Supports Resque for asynchronous sending.'
  spec.homepage      = 'https://github.com/pavel-d/sms-club'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(/\{^bin\/}/) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/\{^(test|spec|features)\/}/)
  spec.require_paths = ['lib']

  spec.add_development_dependency 'webmock', '~> 1.18'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'resque'

  spec.add_runtime_dependency 'faraday', '~> 0.9'
  spec.add_runtime_dependency 'translit', '~> 0.1'
  spec.add_runtime_dependency 'iconv', '~> 1.0'
  spec.add_runtime_dependency 'nokogiri', '~> 1.6'
end

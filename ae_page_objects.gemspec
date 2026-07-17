
# frozen_string_literal: true

require_relative 'lib/ae_page_objects/version'

Gem::Specification.new do |spec|
  spec.name          = 'ae_page_objects'
  spec.version       = AePageObjects::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.author        = 'AppFolio'
  spec.email         = 'opensource@appfolio.com'
  spec.description   = 'A legacy library that provides a customizable implementation of the Page Object pattern built on top of Capybara. It is intended for use in automated acceptance test suites, helping organize and encapsulate page interactions.'
  spec.summary       = 'Customizable Page Object pattern implementation built on top of Capybara.'
  spec.homepage      = 'https://github.com/appfolio/ae_page_objects'
  spec.license       = 'MIT'
  spec.files         = Dir['**/*'].select { |f| f[%r{^(lib/|LICENSE.txt|ae_page_objects\.gemspec)}] }
  spec.require_paths = ['lib']

  spec.required_ruby_version = Gem::Requirement.new('< 4.1')
  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.add_dependency('capybara', ['>= 3', '< 4'])
end

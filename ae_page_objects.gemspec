
# frozen_string_literal: true

require_relative 'lib/ae_page_objects/version'

Gem::Specification.new do |spec|
  spec.name          = 'ae_page_objects'
  spec.version       = AePageObjects::VERSION
  spec.platform      = Gem::Platform::RUBY
  spec.author        = 'AppFolio'
  spec.email         = 'opensource@appfolio.com'
  spec.description   = 'Capybara Page Objects pattern.'
  spec.summary       = spec.description
  spec.homepage      = 'https://github.com/appfolio/ae_page_objects'
  spec.license       = 'MIT'
  spec.files         = Dir['**/*'].select { |f| f[%r{^(lib/|LICENSE.txt|.*gemspec)}] }
  spec.require_paths = ['lib']

  spec.required_ruby_version = Gem::Requirement.new('< 3.4')
  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.add_dependency('capybara', ['>= 3', '< 4'])
end

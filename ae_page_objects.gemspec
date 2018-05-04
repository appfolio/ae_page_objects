$LOAD_PATH << File.expand_path("../lib", __FILE__)
require 'ae_page_objects/version'

Gem::Specification.new do |s|
  s.name                      = "ae_page_objects"
  s.version                   = AePageObjects::VERSION

  s.required_ruby_version     = '>= 2.2.5'
  s.authors                   = ["Donnie Tognazzini"]
  s.description               = "Capybara Page Objects pattern"
  s.email                     = ["engineering@appfolio.com"]

  s.homepage                  = "http://github.com/appfolio/ae_page_objects"
  s.licenses                  = ["MIT"]
  s.require_paths             = ["lib"]
  s.summary                   = "Capybara Page Objects pattern"

  s.files                     = `git ls-files -- lib`.split("\n")

  s.add_dependency('capybara', '~> 3.0')
end


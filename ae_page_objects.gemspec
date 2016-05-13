$LOAD_PATH << File.expand_path("../lib", __FILE__)
require 'ae_page_objects/version'

Gem::Specification.new do |s|
  s.name                      = "ae_page_objects"
  s.version                   = AePageObjects::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors                   = ["Donnie Tognazzini"]
  s.description               = "Capybara Page Objects pattern"
  s.email                     = ["engineering@appfolio.com"]

  s.homepage                  = "http://github.com/appfolio/ae_page_objects"
  s.licenses                  = ["MIT"]
  s.require_paths             = ["lib"]
  s.rubygems_version          = "1.8.24"
  s.summary                   = "Capybara Page Objects pattern"

  s.files                     = `git ls-files -- lib`.split("\n")

  s.add_dependency('capybara', ['>= 1.1', '< 2.8'])
end


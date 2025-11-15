$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "forum/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "forum"
  s.version     = Forum::VERSION
  s.authors     = "Appfolio"
  s.summary     = "forum engine"
  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "> 3"
  s.add_development_dependency "sqlite3"
end

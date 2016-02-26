source "https://rubygems.org"

gem "appraisal", "~> 0.5.1"
gem "mocha", "= 0.13.3"
gem "selenium-webdriver", ">= 0"
gem 'gem-release'
gem 'test-unit'

gemspec

if RUBY_VERSION =~ /\A1\.8/
  gem 'capybara', '~> 1.1.4'
  gem "nokogiri", "< 1.6.0"
  gem 'rubyzip', '< 1.0.0'
  gem 'mime-types', '< 2'
end

if RUBY_VERSION =~ /\A1\.9/
  gem 'mime-types', '~> 2.0'
end

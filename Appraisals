if RUBY_VERSION == '1.8.7'

  appraise "capybara-1.1" do
    gemfile.gemspec

    gem "nokogiri", "< 1.6.0"
    gem 'rubyzip', '< 1.0.0'
    gem 'capybara', '~> 1.1.4'
  end

else

  appraise "capybara-1.1" do
    gemfile.gemspec

    gem 'capybara', '~> 1.1.4'
  end

  appraise "capybara-2.1" do
    gemfile.gemspec

    gem 'capybara', '~> 2.1.0'
  end

  appraise "capybara-2.2" do
    gemfile.gemspec

    gem 'capybara', '~> 2.2.0'
  end

end


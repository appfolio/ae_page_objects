ENV['RAILS_ENV'] = 'test'

require "config/environment"

# Run the migrations
ActiveRecord::Migrator.migrate("#{Rails.root}/db/migrate")

require "rails/test_help"

require 'capybara/dsl'
require 'capybara/rails'

Dir["../../test_helpers/**/*.rb"].each {|f| require f}

module Selenium
  class TestCase < ActiveSupport::TestCase
    include Capybara::DSL
    include AfCruft
    
    # fixtures are added to ActiveSupport::TestCase when rails/test_help is required
    self.use_instantiated_fixtures  = false
    self.use_transactional_fixtures = false
      
    include Rails.application.routes.url_helpers
  end
end

Capybara.configure do |config|
  config.default_driver    = :selenium
  config.default_wait_time = 5
end

require "test/page_objects"


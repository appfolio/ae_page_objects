ENV['RAILS_ENV'] = 'test'

$LOAD_PATH << File.join(File.dirname(__FILE__), '..')

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

    self.use_transactional_fixtures = true
    self.use_instantiated_fixtures  = false

    fixtures :all

    include Rails.application.routes.url_helpers
  end
end

Capybara.configure do |config|
  config.default_driver    = :selenium
  config.default_wait_time = 5
end

require "test/page_objects"


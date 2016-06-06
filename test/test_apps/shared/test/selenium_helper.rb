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

    self.use_instantiated_fixtures  = false
    self.use_transactional_fixtures = false

    fixtures :all

    include Rails.application.routes.url_helpers

    teardown do
      AePageObjects.browser.windows.close_all
    end
  end
end

class TestSeleniumDriver < Capybara::Selenium::Driver

  def initialize(app, options = {})
    options[:profile] ||= Selenium::WebDriver::Firefox::Profile.from_name("selenium") || Selenium::WebDriver::Firefox::Profile.new
    super
  end
end

Capybara.register_driver :ae_page_objects_test_driver do |app|
  TestSeleniumDriver.new(app)
end

Capybara.configure do |config|
  config.default_driver    = :ae_page_objects_test_driver
  config.ignore_hidden_elements = false

  if config.respond_to?(:default_max_wait_time)
    config.default_max_wait_time = 5
  else
    config.default_wait_time = 5
  end
end

require "ae_page_objects/rails"
require "test/page_objects"


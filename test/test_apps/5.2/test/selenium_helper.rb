ENV['RAILS_ENV'] = 'test'

$LOAD_PATH << File.join(File.dirname(__FILE__), '..')

require "config/environment"

# Run the migrations
ActiveRecord::MigrationContext
  .new(ActiveRecord::Migrator.migrations_paths)
  .migrate

require "rails/test_help"

require 'capybara/dsl'
require 'capybara/rails'

module Selenium
  class TestCase < ActiveSupport::TestCase
    include Capybara::DSL

    self.use_instantiated_fixtures  = false
    self.use_transactional_tests = false

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
  Capybara::Selenium::Driver.new(app, options: Selenium::WebDriver::Firefox::Options.new({
    browser: :firefox,
    args: ['--headless']
  }))
end

Capybara.configure do |config|
  config.default_driver = :ae_page_objects_test_driver
  config.server = :puma
  config.default_max_wait_time = 5
end

require "ae_page_objects/rails"
require "test/page_objects"


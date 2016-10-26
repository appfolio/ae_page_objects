$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'ae_page_objects'

require 'selenium-webdriver'

require 'test/unit'
require "mocha/setup"

require 'test_helpers/element_test_helpers'

class AePageObjectsTestCase < Test::Unit::TestCase
  include ElementTestHelpers

  undef_method :default_test if method_defined?(:default_test)

  def setup
    super
    reset_browser
  end

  private

  def reset_browser
    AePageObjects.instance_variable_set(:@browser, nil)
  end

  def stub_current_window
    require 'ae_page_objects/multiple_windows/window_handle_manager'

    capybara_stub
    AePageObjects::MultipleWindows::WindowHandleManager.stubs(:current).returns("window_handle")
  end

  def capybara_stub
    @capybara_stub ||= begin
      browser_stub = stub
      driver_stub = stub(:browser => browser_stub, :invalid_element_errors => [])
      session_stub = stub(:driver => driver_stub)

      Capybara.stubs(:current_session).returns(session_stub)

      stub(:session => session_stub, :browser => browser_stub, :driver => driver_stub)
    end
  end
end
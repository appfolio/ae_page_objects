$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'

require 'selenium-webdriver'
require 'ae_page_objects'
require 'test/unit'
require "mocha/setup"

Dir[File.join(File.dirname(__FILE__), 'test_helpers', '**', '*.rb')].each {|f| require f}

class Test::Unit::TestCase
  include NodeFieldTestHelpers
  include AfCruft

  setup :reset_browser

  def reset_browser
    AePageObjects.instance_variable_set(:@browser, nil)
  end

  def stub_current_window
    capybara_stub
    AePageObjects::MultipleWindows::WindowHandleManager.stubs(:current).returns("window_handle")
  end

  def capybara_stub
    @capybara_stub ||= begin
      browser_stub = stub
      driver_stub = stub(:browser => browser_stub)
      session_stub = stub(:driver => driver_stub)

      Capybara.stubs(:current_session).returns(session_stub)

      stub(:session => session_stub, :browser => browser_stub, :driver => driver_stub)
    end
  end
end

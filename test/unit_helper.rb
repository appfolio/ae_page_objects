$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__), '..')
$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'rubygems'

require 'ae_page_objects'
require 'test/unit'
require "mocha/setup"

Dir[File.join(File.dirname(__FILE__), 'test_helpers', '**', '*.rb')].each {|f| require f}

class Test::Unit::TestCase
  include NodeFieldTestHelpers
  include AfCruft

  def setup
    reset_window_registry
  end

  def stub_current_window
    capybara_stub
    AePageObjects::Window::HandleManager.stubs(:current).returns("window_handle")
  end

  def reset_window_registry
    AePageObjects::Window.instance_variable_set(:@registry, nil)
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

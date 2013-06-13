$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__), '..')
$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'rubygems'

require 'ae_page_objects'
require 'test/unit'
require "mocha/setup"

Dir[File.join(File.dirname(__FILE__), 'test_helpers', '**', '*.rb')].each {|f| require f}

class ActiveSupport::TestCase
  include NodeFieldTestHelpers
  include AfCruft

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

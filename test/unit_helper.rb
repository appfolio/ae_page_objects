$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
$LOAD_PATH << File.join(File.dirname(__FILE__), '..')
$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'rubygems'

require 'ae_page_objects'
require 'test/unit'
require "mocha"

Dir["test/test_helpers/**/*.rb"].each {|f| require f}

class ActiveSupport::TestCase
  include NodeFieldTestHelpers
  include AfCruft
end

require 'unit_helper'

module AePageObjects
  class StaleableTest < Test::Unit::TestCase
  
    def test_stale
      kitty_class = ::AePageObjects::Document.new_subclass
      
      document_stub = mock
      Capybara.stubs(:current_session).returns(document_stub)
      
      kitty_page = kitty_class.new
      assert_equal document_stub, kitty_page.node
      assert_false kitty_page.stale?
      
      document_stub.expects(:find).with("whatever")
      kitty_page.find("whatever")
      
      kitty_page.send(:stale!)
      assert kitty_page.stale?
      
      assert_raises AePageObjects::StalePageObject do
        kitty_page.find("whatever")
      end
    end
  end
end

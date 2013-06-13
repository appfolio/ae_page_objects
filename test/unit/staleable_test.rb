require 'unit_helper'

module AePageObjects
  class StaleableTest < Test::Unit::TestCase
  
    def test_stale
      kitty_class = ::AePageObjects::Document.new_subclass

      capybara_stub.browser.expects(:window_handle).returns("window_handle")
      
      kitty_page = kitty_class.new
      assert_equal capybara_stub.session, kitty_page.node
      assert_false kitty_page.stale?

      capybara_stub.session.expects(:find).with("whatever")
      kitty_page.find("whatever")
      
      kitty_page.send(:stale!)
      assert kitty_page.stale?
      
      assert_raises AePageObjects::StalePageObject do
        kitty_page.find("whatever")
      end
    end
  end
end

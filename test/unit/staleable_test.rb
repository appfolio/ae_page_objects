require 'unit_helper'

module AePageObjects
  class StaleableTest < AePageObjectsTestCase

    def test_stale
      kitty_class = Class.new(AePageObjects::Document)

      stub_current_window

      kitty_page = kitty_class.new
      assert_equal capybara_stub.session, kitty_page.node
      assert_false kitty_page.stale?

      capybara_stub.session.expects(:find).with("whatever")
      kitty_page.find("whatever")

      kitty_page.stale!
      assert kitty_page.stale?

      assert_raises AePageObjects::StalePageObject do
        kitty_page.find("whatever")
      end
    end
  end
end

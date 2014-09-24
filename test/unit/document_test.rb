require 'unit_helper'

module AePageObjects
  class DocumentTest < Test::Unit::TestCase

    def test_document
      kitty_class = ::AePageObjects::Document.new_subclass

      stub_current_window

      kitty_page = kitty_class.new

      assert_equal capybara_stub.session, kitty_page.node

      capybara_stub.session.expects(:current_url).returns("https://somejunk/yo/dude?as-if=homie")
      assert_equal "/yo/dude?as-if=homie", kitty_page.current_url

      capybara_stub.session.expects(:current_url).returns("https://somejunk/yo/dude?as-if=homie")
      assert_equal "/yo/dude", kitty_page.current_url_without_params
    end

    def test_find
      kitty_class = ::AePageObjects::Document.new_subclass

      stub_current_window

      kitty_page = kitty_class.new

      capybara_stub.session.expects(:find).with(1, 2).returns("result")
      assert_equal "result", kitty_page.find(1, 2)

      capybara_stub.session.expects(:find).with("hello kids").returns("result")
      kitty_page.find("hello kids")

      capybara_stub.session.expects(:find).with(:xpath, "yo").returns("result")
      kitty_page.find(:xpath, "yo")
    end
  end
end

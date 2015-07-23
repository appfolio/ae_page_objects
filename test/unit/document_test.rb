require 'unit_helper'

module AePageObjects
  class DocumentTest < Test::Unit::TestCase
    include NodeInterfaceTests

    def test_document
      kitty_class = Class.new(AePageObjects::Document)

      stub_current_window

      kitty_page = kitty_class.new

      assert_equal capybara_stub.session, kitty_page.node

      capybara_stub.session.expects(:current_url).returns("https://somejunk/yo/dude?as-if=homie")
      assert_equal "/yo/dude?as-if=homie", kitty_page.current_url

      capybara_stub.session.expects(:current_url).returns("https://somejunk/yo/dude?as-if=homie")
      assert_equal "/yo/dude", kitty_page.current_url_without_params

      capybara_stub.session.expects(:current_url).returns("https://somejunk/yo/dude?as-if=homie#whatever")
      assert_equal "/yo/dude?as-if=homie#whatever", kitty_page.current_url

      capybara_stub.session.expects(:current_url).returns("https://somejunk/yo/dude?as-if=homie#whatever")
      assert_equal "/yo/dude", kitty_page.current_url_without_params

      capybara_stub.session.expects(:current_url).returns("https://somejunk/yo/dude#whatever")
      assert_equal "/yo/dude#whatever", kitty_page.current_url

      capybara_stub.session.expects(:current_url).returns("https://somejunk/yo/dude#whatever")
      assert_equal "/yo/dude", kitty_page.current_url_without_params

    end

    def test_find
      kitty_class = Class.new(AePageObjects::Document)

      stub_current_window

      kitty_page = kitty_class.new

      capybara_stub.session.expects(:find).with(1, 2).returns("result")
      assert_equal "result", kitty_page.find(1, 2)

      capybara_stub.session.expects(:find).with("hello kids").returns("result")
      kitty_page.find("hello kids")

      capybara_stub.session.expects(:find).with(:xpath, "yo").returns("result")
      kitty_page.find(:xpath, "yo")
    end

    def test_ensure_loaded
      some_document_class = Class.new(AePageObjects::Document) do
        def loaded_locator
          "#hello"
        end
      end
      some_document_class.expects(:can_load_from_current_url?).returns(true)

      element_error = LoadingElementFailed.new("Twas an error")
      some_document_class.any_instance.expects(:find).with("#hello").raises(element_error)

      raised = assert_raises LoadingPageFailed do
        some_document_class.new
      end

      assert_equal element_error.message, raised.message
    end

  private

    def node_for_node_tests
      page_klass = Class.new(AePageObjects::Document)
      stub_current_window
      page_klass.new
    end
  end
end

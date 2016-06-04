require 'unit_helper'

module AePageObjects
  class DocumentTest < AePageObjectsTestCase
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

    def test_stale
      kitty_class = Class.new(AePageObjects::Document)

      stub_current_window

      kitty_page = kitty_class.new
      assert_equal capybara_stub.session, kitty_page.node
      assert_false kitty_page.stale?

      kitty_page.stale!
      assert kitty_page.stale?

      assert_raises AePageObjects::StalePageObject do
        kitty_page.find("whatever")
      end
    end

    def test_visit
      show_page = Class.new(AePageObjects::Document) do
        path :show_book
        path :view_book
      end

      router = mock
      show_page.router = router

      book           = stub
      something      = stub
      something_else = stub
      full_path      = stub

      show_page.stubs(:new)
      capybara_stub.session.stubs(:visit).with(full_path).returns(stub)

      router.expects(:generate_path).with(:show_book, book, :format => :json).returns(full_path)
      show_page.visit(book, :format => :json)

      router.expects(:generate_path).with(:view_book, book, :format => :json).returns(full_path)
      show_page.visit(book, :format => :json, :via => :view_book)

      router.expects(:generate_path).with(:show_book, something, something_else).returns(full_path)
      show_page.visit(something, something_else)

      router.expects(:generate_path).with('something', something, something_else, {}).returns(full_path)
      show_page.visit(something, something_else, :via => 'something')

      router.expects(:generate_path).with(:show_book, something, something_else, {:param => 'param1'}).returns(full_path)
      show_page.visit(something, something_else, :param => 'param1')
    end

    def test_router
      page_class = Class.new(AePageObjects::Document)

      AePageObjects.router_factory.expects(:router_for).with(page_class).returns(:blah)
      assert_equal :blah, page_class.router

      # test memoization
      assert_equal :blah, page_class.router
    end

    private

    def node_for_node_tests
      page_klass = Class.new(AePageObjects::Document)
      stub_current_window
      page_klass.new
    end
  end
end

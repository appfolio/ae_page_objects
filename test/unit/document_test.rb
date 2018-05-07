require 'unit_helper'

require 'test_helpers/node_interface_tests'

module AePageObjects
  class DocumentTest < AePageObjectsTestCase
    include NodeInterfaceTests

    def teardown
      AePageObjects::Document.router = nil
      super
    end

    def test_new__is_not_loaded__raises_loading_page_failed
      capybara_stub

      some_document_class = Class.new(AePageObjects::Document)
      some_document_class.any_instance.stubs(:is_loaded?).returns(false)
      AePageObjects.stubs(:default_max_wait_time).returns(0)

      raised = assert_raises LoadingPageFailed do
        some_document_class.new
      end
    end

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

    def test_stale
      kitty_class = Class.new(AePageObjects::Document)

      stub_current_window

      kitty_page = kitty_class.new
      assert_equal capybara_stub.session, kitty_page.node
      refute kitty_page.stale?

      kitty_page.stale!
      assert kitty_page.stale?

      assert_raises AePageObjects::StalePageObject do
        kitty_page.node.find("whatever")
      end
    end

    def test_visit
      show_page = Class.new(AePageObjects::Document) do
        path :show_book
        path :view_book
      end

      router           = mock
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

      AePageObjects.expects(:default_router).returns(:blah)
      assert_equal :blah, page_class.router

      # test memoization
      assert_equal :blah, page_class.router
    end

    def test_router__inheritance
      page_1 = Class.new(AePageObjects::Document)
      page_1_2 = Class.new(page_1)

      page_2 = Class.new(AePageObjects::Document)
      page_2_2 = Class.new(page_2)
      page_2_3 = Class.new(page_2)
      page_2_3_2 = Class.new(page_2_3)

      router1 = Object.new
      router2 = Object.new

      page_1.router = router1
      page_2_3.router = router2

      assert_equal AePageObjects.default_router, AePageObjects::Document.router

      assert_equal router1, page_1.router
      assert_equal router1, page_1_2.router

      assert_equal AePageObjects.default_router, page_2.router
      assert_equal page_2.router, page_2_2.router
      assert_equal router2, page_2_3.router
      assert_equal router2, page_2_3_2.router

      # verify memoization
      page_2_3.router = nil
      assert_equal router2, page_2_3_2.router
    end

    def test_reload
      kitty_class = Class.new(AePageObjects::Document)

      stub_current_window

      kitty_page = kitty_class.new
      capybara_stub.session.driver.expects(:execute_script).with do |script|
        [
          "document.body.classList.add('ae_page_objects-reloading');",
          'location.reload(true);'
        ].all? { |line| script.include?(line) }
      end

      capybara_node = stub(:allow_reload!)

      kitty_page
        .node
        .expects(:first)
        .with('body.ae_page_objects-reloading', minimum: 0)
        .times(4)
        .returns(capybara_node, capybara_node, capybara_node, nil)

      kitty_page.expects(:ensure_loaded!)

      new_page = kitty_page.reload
      assert_equal new_page, kitty_page
    end

    private

    def node_for_node_tests
      page_klass = Class.new(AePageObjects::Document)
      stub_current_window
      page_klass.new
    end
  end
end

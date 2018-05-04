require 'unit_helper'

require 'test_helpers/node_interface_tests'

module AePageObjects
  class ElementTest < AePageObjectsTestCase
    include NodeInterfaceTests

    def test_new__no_name_no_locator
      pet_class   = Class.new(AePageObjects::Document)
      kitty_class = Class.new(AePageObjects::Element)

      stub_current_window

      pet           = pet_class.new

      error = assert_raises ArgumentError do
        kitty_class.new(pet)
      end

      assert_include error.message, ":name or :locator is required"
    end

    def test_new
      pet_class   = Class.new(AePageObjects::Document)
      kitty_class = Class.new(AePageObjects::Element)

      stub_current_window

      pet           = pet_class.new

      kitty_page_object = stub(:allow_reload!)
      capybara_stub.session.expects(:first).with("#tiger", minimum: 0).returns(kitty_page_object)
      kitty = kitty_class.new(pet, :locator => '#tiger')

      assert_equal pet, kitty.parent
      assert_equal kitty_page_object, kitty.node
      assert_equal nil, kitty.full_name
      assert_equal nil, kitty.name
      refute kitty.using_default_locator?
    end

    def test_new__with_name
      pet_class   = Class.new(AePageObjects::Document)
      kitty_class = Class.new(AePageObjects::Element)

      stub_current_window

      pet           = pet_class.new

      kitty_page_object = stub(:allow_reload!)
      capybara_stub.session.expects(:first).with("#tiger", minimum: 0).returns(kitty_page_object)
      kitty = kitty_class.new(pet, :name => 'tiger')

      assert_equal pet, kitty.parent
      assert_equal kitty_page_object, kitty.node
      assert_equal "tiger", kitty.full_name
      assert_equal "tiger", kitty.name
      assert kitty.using_default_locator?
    end

    def test_new__locator
      pet_class   = Class.new(AePageObjects::Document)
      kitty_class = Class.new(AePageObjects::Element)

      capybara_stub

      pet           = pet_class.new

      kitty_page_object = stub(:allow_reload!)
      capybara_stub.session.expects(:first).with("J 2da K", minimum: 0).returns(kitty_page_object)
      kitty = kitty_class.new(pet, :name => 'tiger', :locator => "J 2da K")

      assert_equal pet, kitty.parent
      assert_equal kitty_page_object, kitty.node
      assert_equal "tiger", kitty.full_name
      assert_equal "tiger", kitty.name
      refute kitty.using_default_locator?
    end

    def test_new__cannot_find_scoped_node__raises_loading_element_failed
      kitty_page_class = Class.new(AePageObjects::Document)
      kitty_class      = Class.new(AePageObjects::Element)

      capybara_stub
      capybara_stub.session.stubs(:first).with('#hi', minimum: 0).raises(Capybara::ElementNotFound)
      AePageObjects.stubs(:default_max_wait_time).returns(0)

      raised = assert_raises LoadingElementFailed do
        kitty_class.new(kitty_page_class.new, '#hi')
      end
    end

    def test_new__is_not_loaded__raises_loading_element_failed
      kitty_page_class = Class.new(AePageObjects::Document)
      kitty_class      = Class.new(AePageObjects::Element)
      kitty_class.any_instance.stubs(:is_loaded?).returns(false)

      kitty_page_object = stub(:allow_reload!)

      capybara_stub
      capybara_stub.session.stubs(:first).with('#hi', minimum: 0).returns(kitty_page_object)
      AePageObjects.stubs(:default_max_wait_time).returns(0)

      raised = assert_raises LoadingElementFailed do
        kitty_class.new(kitty_page_class.new, '#hi')
      end
    end

    def test_document
      kitty_page_class = Class.new(AePageObjects::Document)
      kitty_class      = Class.new(AePageObjects::Element)

      capybara_stub

      kitty_page    = kitty_page_class.new
      assert_equal kitty_page, kitty_page.document

      capybara_stub.session.stubs(:allow_reload!)
      capybara_stub.session.stubs(:first).returns(capybara_stub.session)

      kitty1 = kitty_class.new(kitty_page, :name => 'tiger')
      kitty2 = kitty_class.new(kitty1,     :name => 'tiger')
      kitty3 = kitty_class.new(kitty2,     :name => 'tiger')

      assert_equal kitty_page, kitty1.parent
      assert_equal kitty1, kitty2.parent
      assert_equal kitty2, kitty3.parent

      assert_equal kitty_page, kitty1.document
      assert_equal kitty_page, kitty2.document
      assert_equal kitty_page, kitty3.document
    end

    def test_full_name
      kitty_page_class = AePageObjects::Document
      kitty_class      = Class.new(AePageObjects::Element) do
        def configure(*)
          super
          @name = nil
        end
      end

      capybara_stub

      kitty_page = kitty_page_class.new
      capybara_stub.session.stubs(:allow_reload!)
      capybara_stub.session.stubs(:first).returns(capybara_stub.session)

      kitty1 = kitty_class.new(kitty_page, :locator => 'purr')
      assert_nil kitty1.full_name

      kitty2 = kitty_class.new(kitty1, :locator => 'purr')
      assert_nil kitty2.full_name
    end

    def test_stale
      pet_class   = Class.new(AePageObjects::Document)
      kitty_class = Class.new(AePageObjects::Element)

      stub_current_window

      pet = pet_class.new

      kitty_capybara_node = stub(:allow_reload!)

      capybara_stub.session.expects(:first).with("#tiger", minimum: 0).returns(kitty_capybara_node)
      kitty_element = kitty_class.new(pet, :locator => '#tiger')

      assert_equal kitty_capybara_node, kitty_element.node
      refute kitty_element.stale?

      kitty_element.stale!
      assert kitty_element.stale?

      assert_raises AePageObjects::StalePageObject do
        kitty_element.node.find("whatever")
      end
    end

    private

    def node_for_node_tests
      page_klass    = Class.new(AePageObjects::Document)
      element_klass = Class.new(AePageObjects::Element)
      stub_current_window

      element_klass.any_instance.stubs(:scoped_node => capybara_stub.session)

      element_klass.new(page_klass.new, :locator => "#foo")
    end
  end
end

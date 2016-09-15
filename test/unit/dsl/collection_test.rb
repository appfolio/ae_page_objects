require 'unit_helper'

module AePageObjects
  module Dsl
    class CollectionTest < AePageObjectsTestCase

      def test_collection__no_is__no_contains__block
        kitty = Class.new(AePageObjects::Document) do
          collection :previous_owners do
            element :owner_name
            element :kitty_name_during_ownership
          end
        end

        verify_kitty_structure(kitty)

        stub_current_window

        jon = kitty.new

        previous_owners_page_object = mock
        capybara_stub.session.expects(:find).with("#previous_owners").returns(previous_owners_page_object)

        previous_owners = verify_element_on_parent_with_intermediary_class(jon, :previous_owners, AePageObjects::Collection, previous_owners_page_object)

        first_owner_page_object = mock
        previous_owners_page_object.expects(:all).with(:xpath,  ".//*", {}).returns([first_owner_page_object])
        previous_owners_page_object.expects(:find).with(:xpath, ".//*[1]", {}).returns(first_owner_page_object)
        first_owner = verify_item_element_with_intermediary_class(previous_owners, 0, AePageObjects::Element, first_owner_page_object)

        owner_name_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_owner_name").returns(owner_name_page_object)
        verify_element_on_parent(first_owner, :owner_name, AePageObjects::Element, owner_name_page_object)

        kitty_name_during_ownership_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_kitty_name_during_ownership").returns(kitty_name_during_ownership_page_object)
        verify_element_on_parent(first_owner, :kitty_name_during_ownership, AePageObjects::Element, kitty_name_during_ownership_page_object)
      end

      def test_collection__is__no_contains__block
        previous_owners_class = Class.new(AePageObjects::Collection)
        previous_owners_class.item_class = Class.new(AePageObjects::Element)

        kitty = Class.new(AePageObjects::Document) do
          collection :previous_owners, :is => previous_owners_class do
            element :owner_name
            element :kitty_name_during_ownership
          end
        end

        verify_kitty_structure(kitty)

        stub_current_window

        jon = kitty.new

        previous_owners_page_object = mock
        capybara_stub.session.expects(:find).with("#previous_owners").returns(previous_owners_page_object)

        previous_owners = verify_element_on_parent_with_intermediary_class(jon, :previous_owners, previous_owners_class, previous_owners_page_object)

        first_owner_page_object = mock

        previous_owners_page_object.expects(:all).with(:xpath, ".//*", {}).returns([first_owner_page_object])
        previous_owners_page_object.expects(:find).with(:xpath, ".//*[1]", {}).returns(first_owner_page_object)
        first_owner = verify_item_element_with_intermediary_class(previous_owners, 0, previous_owners_class.item_class, first_owner_page_object)

        owner_name_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_owner_name").returns(owner_name_page_object)
        verify_element_on_parent(first_owner, :owner_name, AePageObjects::Element, owner_name_page_object)

        kitty_name_during_ownership_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_kitty_name_during_ownership").returns(kitty_name_during_ownership_page_object)
        verify_element_on_parent(first_owner, :kitty_name_during_ownership, AePageObjects::Element, kitty_name_during_ownership_page_object)
      end

      def test_collection__is__no_contains__block__no_item_class
        previous_owners_class = Class.new(AePageObjects::Collection)

        kitty = Class.new(AePageObjects::Document) do
          collection :previous_owners, :is => previous_owners_class do
            element :owner_name
            element :kitty_name_during_ownership
          end
        end

        verify_kitty_structure(kitty)

        stub_current_window

        jon = kitty.new

        previous_owners_page_object = mock
        capybara_stub.session.expects(:find).with("#previous_owners").returns(previous_owners_page_object)

        previous_owners = verify_element_on_parent_with_intermediary_class(jon, :previous_owners, previous_owners_class, previous_owners_page_object)

        first_owner_page_object = mock

        previous_owners_page_object.expects(:all).with(:xpath, ".//*", {}).returns([first_owner_page_object])
        previous_owners_page_object.expects(:find).with(:xpath, ".//*[1]", {}).returns(first_owner_page_object)
        first_owner = verify_item_element_with_intermediary_class(previous_owners, 0, previous_owners_class.item_class, first_owner_page_object)

        owner_name_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_owner_name").returns(owner_name_page_object)
        verify_element_on_parent(first_owner, :owner_name, AePageObjects::Element, owner_name_page_object)

        kitty_name_during_ownership_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_kitty_name_during_ownership").returns(kitty_name_during_ownership_page_object)
        verify_element_on_parent(first_owner, :kitty_name_during_ownership, AePageObjects::Element, kitty_name_during_ownership_page_object)
      end

      def test_collection__is__no_contains__no_block
        previous_owner_class = Class.new(AePageObjects::Element) do
          element :owner_name
          element :kitty_name_during_ownership
        end

        previous_owners_class = Class.new(AePageObjects::Collection)
        previous_owners_class.item_class = previous_owner_class

        kitty = Class.new(AePageObjects::Document) do
          collection :previous_owners, :is => previous_owners_class
        end

        verify_kitty_structure(kitty)

        stub_current_window

        jon = kitty.new

        previous_owners_page_object = mock
        capybara_stub.session.expects(:find).with("#previous_owners").returns(previous_owners_page_object)

        previous_owners = verify_element_on_parent(jon, :previous_owners, previous_owners_class, previous_owners_page_object)

        first_owner_page_object = mock
        previous_owners_page_object.expects(:all).with(:xpath,  ".//*", {}).returns([first_owner_page_object])
        previous_owners_page_object.expects(:find).with(:xpath, ".//*[1]", {}).returns(first_owner_page_object)
        first_owner = verify_item_element(previous_owners, 0, previous_owner_class, first_owner_page_object)

        owner_name_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_owner_name").returns(owner_name_page_object)
        verify_element_on_parent(first_owner, :owner_name, AePageObjects::Element, owner_name_page_object)

        kitty_name_during_ownership_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_kitty_name_during_ownership").returns(kitty_name_during_ownership_page_object)
        verify_element_on_parent(first_owner, :kitty_name_during_ownership, AePageObjects::Element, kitty_name_during_ownership_page_object)
      end

      def test_collection__is__contains__no_block__same_item_class
        previous_owner_class = Class.new(AePageObjects::Element) do
          element :owner_name
          element :kitty_name_during_ownership
        end

        previous_owners_class = Class.new(AePageObjects::Collection)
        previous_owners_class.item_class = previous_owner_class

        kitty = Class.new(AePageObjects::Document) do
          collection :previous_owners, :is => previous_owners_class, :contains => previous_owner_class
        end

        verify_kitty_structure(kitty)

        stub_current_window

        jon = kitty.new

        previous_owners_page_object = mock
        capybara_stub.session.expects(:find).with("#previous_owners").returns(previous_owners_page_object)

        previous_owners = verify_element_on_parent(jon, :previous_owners, previous_owners_class, previous_owners_page_object)

        first_owner_page_object = mock
        previous_owners_page_object.expects(:all).with(:xpath,  ".//*", {}).returns([first_owner_page_object])
        previous_owners_page_object.expects(:find).with(:xpath, ".//*[1]", {}).returns(first_owner_page_object)
        first_owner = verify_item_element(previous_owners, 0, previous_owner_class, first_owner_page_object)

        owner_name_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_owner_name").returns(owner_name_page_object)
        verify_element_on_parent(first_owner, :owner_name, AePageObjects::Element, owner_name_page_object)

        kitty_name_during_ownership_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_kitty_name_during_ownership").returns(kitty_name_during_ownership_page_object)
        verify_element_on_parent(first_owner, :kitty_name_during_ownership, AePageObjects::Element, kitty_name_during_ownership_page_object)
      end

      def test_collection__is__contains__no_block__different_item_class
        previous_owner_class = Class.new(AePageObjects::Element) do
          element :owner_name
          element :kitty_name_during_ownership
        end

        previous_owners_class = Class.new(AePageObjects::Collection)

        kitty = Class.new(AePageObjects::Document) do
          collection :previous_owners, :is => previous_owners_class, :contains => previous_owner_class
        end

        verify_kitty_structure(kitty)

        stub_current_window
        jon = kitty.new

        previous_owners_page_object = mock
        capybara_stub.session.expects(:find).with("#previous_owners").returns(previous_owners_page_object)

        previous_owners = verify_element_on_parent_with_intermediary_class(jon, :previous_owners, previous_owners_class, previous_owners_page_object)

        first_owner_page_object = mock
        previous_owners_page_object.expects(:all).with(:xpath,  ".//*", {}).returns([first_owner_page_object])
        previous_owners_page_object.expects(:find).with(:xpath, ".//*[1]", {}).returns(first_owner_page_object)
        first_owner = verify_item_element(previous_owners, 0, previous_owner_class, first_owner_page_object)

        owner_name_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_owner_name").returns(owner_name_page_object)
        verify_element_on_parent(first_owner, :owner_name, AePageObjects::Element, owner_name_page_object)

        kitty_name_during_ownership_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_kitty_name_during_ownership").returns(kitty_name_during_ownership_page_object)
        verify_element_on_parent(first_owner, :kitty_name_during_ownership, AePageObjects::Element, kitty_name_during_ownership_page_object)
      end

      def test_collection__no_is__contains__no_block
        previous_owner_class = Class.new(AePageObjects::Element) do
          element :owner_name
          element :kitty_name_during_ownership
        end

        kitty = Class.new(AePageObjects::Document) do
          collection :previous_owners, :contains => previous_owner_class
        end

        verify_kitty_structure(kitty)

        stub_current_window
        jon = kitty.new

        previous_owners_page_object = mock
        capybara_stub.session.expects(:find).with("#previous_owners").returns(previous_owners_page_object)

        previous_owners = verify_element_on_parent_with_intermediary_class(jon, :previous_owners, AePageObjects::Collection, previous_owners_page_object)

        first_owner_page_object = mock
        previous_owners_page_object.expects(:all).with(:xpath,  ".//*", {}).returns([first_owner_page_object])
        previous_owners_page_object.expects(:find).with(:xpath, ".//*[1]", {}).returns(first_owner_page_object)
        first_owner = verify_item_element(previous_owners, 0, previous_owner_class, first_owner_page_object)

        owner_name_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_owner_name").returns(owner_name_page_object)
        verify_element_on_parent(first_owner, :owner_name, AePageObjects::Element, owner_name_page_object)

        kitty_name_during_ownership_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_kitty_name_during_ownership").returns(kitty_name_during_ownership_page_object)
        verify_element_on_parent(first_owner, :kitty_name_during_ownership, AePageObjects::Element, kitty_name_during_ownership_page_object)
      end

      def test_collection__no_is__contains__block
        previous_owner_class = Class.new(AePageObjects::Element) do
          element :owner_name
        end

        kitty = Class.new(AePageObjects::Document) do
          collection :previous_owners, :contains => previous_owner_class do
            element :kitty_name_during_ownership
          end
        end

        verify_kitty_structure(kitty)

        stub_current_window

        jon = kitty.new

        previous_owners_page_object = mock
        capybara_stub.session.expects(:find).with("#previous_owners").returns(previous_owners_page_object)

        previous_owners = verify_element_on_parent_with_intermediary_class(jon, :previous_owners, AePageObjects::Collection, previous_owners_page_object)

        first_owner_page_object = mock
        previous_owners_page_object.expects(:all).with(:xpath,  ".//*", {}).returns([first_owner_page_object])
        previous_owners_page_object.expects(:find).with(:xpath, ".//*[1]", {}).returns(first_owner_page_object)
        first_owner = verify_item_element_with_intermediary_class(previous_owners, 0, previous_owner_class, first_owner_page_object)

        owner_name_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_owner_name").returns(owner_name_page_object)
        verify_element_on_parent(first_owner, :owner_name, AePageObjects::Element, owner_name_page_object)

        kitty_name_during_ownership_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_kitty_name_during_ownership").returns(kitty_name_during_ownership_page_object)
        verify_element_on_parent(first_owner, :kitty_name_during_ownership, AePageObjects::Element, kitty_name_during_ownership_page_object)
      end

      def test_collection__is__contains__block
        previous_owner_class = Class.new(AePageObjects::Element) do
          element :owner_name
        end

        previous_owners_class_item_class = Class.new(AePageObjects::Element)

        previous_owners_class = Class.new(AePageObjects::Collection)
        previous_owners_class.item_class = previous_owners_class_item_class

        kitty = Class.new(AePageObjects::Document) do
          collection :previous_owners,
                     :is => previous_owners_class,
                     :contains => previous_owner_class do
            element :kitty_name_during_ownership
          end
        end

        verify_kitty_structure(kitty)

        stub_current_window

        jon = kitty.new

        previous_owners_page_object = mock
        capybara_stub.session.expects(:find).with("#previous_owners").returns(previous_owners_page_object)

        previous_owners = verify_element_on_parent_with_intermediary_class(jon, :previous_owners, previous_owners_class, previous_owners_page_object)

        first_owner_page_object = mock
        previous_owners_page_object.expects(:all).with(:xpath,  ".//*", {}).returns([first_owner_page_object])
        previous_owners_page_object.expects(:find).with(:xpath, ".//*[1]", {}).returns(first_owner_page_object)
        first_owner = verify_item_element_with_intermediary_class(previous_owners, 0, previous_owner_class, first_owner_page_object)

        owner_name_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_owner_name").returns(owner_name_page_object)
        verify_element_on_parent(first_owner, :owner_name, AePageObjects::Element, owner_name_page_object)

        kitty_name_during_ownership_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_kitty_name_during_ownership").returns(kitty_name_during_ownership_page_object)
        verify_element_on_parent(first_owner, :kitty_name_during_ownership, AePageObjects::Element, kitty_name_during_ownership_page_object)
      end

      def test_collection__no_is__no_contains__no_block
        kitty = Class.new(AePageObjects::Document) do
          collection :previous_owners
        end

        stub_current_window

        jon = kitty.new

        previous_owners_page_object = mock
        capybara_stub.session.expects(:find).with("#previous_owners").returns(previous_owners_page_object)

        previous_owners = verify_element_on_parent_with_intermediary_class(jon, :previous_owners, AePageObjects::Collection, previous_owners_page_object)

        first_owner_page_object = mock
        previous_owners_page_object.expects(:all).with(:xpath,  ".//*", {}).returns([first_owner_page_object])
        previous_owners_page_object.expects(:find).with(:xpath, ".//*[1]", {}).returns(first_owner_page_object)
        first_owner = verify_item_element(previous_owners, 0, AePageObjects::Element, first_owner_page_object)
      end

      def test_collection__locator
        kitty = Class.new(AePageObjects::Document) do
          collection :previous_owners, :locator => "whatever you want, baby" do
            element :owner_name
            element :kitty_name_during_ownership, :locator => "Kitty Name"
          end
        end

        verify_kitty_structure(kitty)

        stub_current_window

        jon = kitty.new

        previous_owners_page_object = mock
        capybara_stub.session.expects(:find).with("whatever you want, baby").returns(previous_owners_page_object)

        previous_owners = verify_element_on_parent_with_intermediary_class(jon, :previous_owners, AePageObjects::Collection, previous_owners_page_object)

        first_owner_page_object = mock
        previous_owners_page_object.expects(:all).with(:xpath,  ".//*", {}).returns([first_owner_page_object])
        previous_owners_page_object.expects(:find).with(:xpath, ".//*[1]", {}).returns(first_owner_page_object)
        first_owner = verify_item_element_with_intermediary_class(previous_owners, 0, AePageObjects::Element, first_owner_page_object)

        owner_name_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_owner_name").returns(owner_name_page_object)
        verify_element_on_parent(first_owner, :owner_name, AePageObjects::Element, owner_name_page_object)

        kitty_name_during_ownership_page_object = mock
        first_owner_page_object.expects(:find).with("Kitty Name").returns(kitty_name_during_ownership_page_object)
        verify_element_on_parent(first_owner, :kitty_name_during_ownership, AePageObjects::Element, kitty_name_during_ownership_page_object)
      end

      def test_nested_element__locator__proc
        kitty = Class.new(AePageObjects::Document) do
          collection :previous_owners, :locator => Proc.new { parent.page_local_context } do
            element :owner_name
            element :kitty_name_during_ownership, :locator => Proc.new { parent.page_local_context }
          end
        end

        verify_kitty_structure(kitty)

        stub_current_window

        jon = kitty.new

        jon.expects(:page_local_context).returns("hello")

        previous_owners_page_object = mock
        capybara_stub.session.expects(:find).with("hello").returns(previous_owners_page_object)

        previous_owners = verify_element_on_parent_with_intermediary_class(jon, :previous_owners, AePageObjects::Collection, previous_owners_page_object)

        first_owner_page_object = mock
        previous_owners_page_object.expects(:all).with(:xpath,  ".//*", {}).returns([first_owner_page_object])
        previous_owners_page_object.expects(:find).with(:xpath, ".//*[1]", {}).returns(first_owner_page_object)
        first_owner = verify_item_element_with_intermediary_class(previous_owners, 0, AePageObjects::Element, first_owner_page_object)

        owner_name_page_object = mock
        first_owner_page_object.expects(:find).with("#previous_owners_0_owner_name").returns(owner_name_page_object)
        verify_element_on_parent(first_owner, :owner_name, AePageObjects::Element, owner_name_page_object)

        kitty_name_during_ownership_page_object = mock
        first_owner_page_object.expects(:find).with("Milkshake").returns(kitty_name_during_ownership_page_object)

        first_owner.expects(:page_local_context).returns("Milkshake")

        verify_element_on_parent(first_owner, :kitty_name_during_ownership, AePageObjects::Element, kitty_name_during_ownership_page_object)
      end

    private

      def verify_kitty_structure(kitty_class)
        assert_equal [:previous_owners], kitty_class.element_attributes.keys
        assert_equal [:kitty_name_during_ownership, :owner_name], kitty_class.element_attributes[:previous_owners].item_class.element_attributes.keys.sort
      end

      def verify_item_element(collection, index, expected_item_type, expected_item_page)
        collection[index].tap do |item|
          assert       item.is_a?(AePageObjects::ElementProxy)
          assert_equal expected_item_type, item.class
          assert_equal collection.item_class, item.class
          assert_equal expected_item_page, item.node
          assert_equal collection, item.parent
        end
      end

      def verify_item_element_with_intermediary_class(collection, index, expected_item_type, expected_item_page)
        collection[index].tap do |item|
          assert       item.is_a?(AePageObjects::ElementProxy)
          assert_equal expected_item_type, item.class.superclass
          assert_equal collection.item_class, item.class
          assert_equal expected_item_page, item.node
          assert_equal collection, item.parent
        end
      end
    end
  end
end

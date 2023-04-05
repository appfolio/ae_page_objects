require 'unit_helper'

module AePageObjects
  module Dsl
    class ElementTest < AePageObjectsTestCase
      def test_element__basic
        kitty = Class.new(AePageObjects::Document) do
          element :kind
        end

        assert kitty.method_defined?(:kind)
        assert_equal [:kind], kitty.element_attributes.keys

        stub_current_window
        jon = kitty.new

        kind_page_object = stub("kind_page_object", allow_reload!: nil)
        capybara_stub.session.expects(:first).with("#kind", { minimum: 0 }).returns(kind_page_object)
        verify_element_on_parent(jon, :kind, AePageObjects::Element, kind_page_object)
      end

      def test_element__locator
        kitty = Class.new(AePageObjects::Document) do
          element :kind, :locator => "Kind Homie"
        end

        assert kitty.method_defined?(:kind)
        assert_equal [:kind], kitty.element_attributes.keys

        stub_current_window

        jon = kitty.new

        kind_page_object = stub("kind_page_object", allow_reload!: nil)
        capybara_stub.session.expects(:first).with("Kind Homie", { minimum: 0 }).returns(kind_page_object)
        verify_element_on_parent(jon, :kind, AePageObjects::Element, kind_page_object)
      end

      def test_element__locator__proc
        kitty = Class.new(AePageObjects::Document) do
          element :kind, :locator => Proc.new { parent.page_local_context }

          def page_local_context; end
        end

        assert kitty.method_defined?(:kind)
        assert_equal [:kind], kitty.element_attributes.keys

        stub_current_window

        jon = kitty.new
        jon.expects(:page_local_context).returns("hello")

        kind_page_object = stub("kind_page_object", allow_reload!: nil)
        capybara_stub.session.expects(:first).with("hello", { minimum: 0 }).returns(kind_page_object)
        verify_element_on_parent(jon, :kind, AePageObjects::Element, kind_page_object)
      end

      def test_element__is__select
        kitty = Class.new(AePageObjects::Document) do
          element :kind, :is => AePageObjects::Select
        end

        assert kitty.method_defined?(:kind)
        assert_equal [:kind], kitty.element_attributes.keys

        stub_current_window

        jon = kitty.new

        kind_page_object = stub("kind_page_object", allow_reload!: nil)
        capybara_stub.session.expects(:first).with("#kind", { minimum: 0 }).returns(kind_page_object)
        verify_element_on_parent(jon, :kind, AePageObjects::Select, kind_page_object)
      end

      def test_element__is__checkbox
        kitty = Class.new(AePageObjects::Document) do
          element :kind, :is => AePageObjects::Checkbox
        end

        assert kitty.method_defined?(:kind)
        assert_equal [:kind], kitty.element_attributes.keys

        stub_current_window

        jon = kitty.new

        kind_page_object = stub("kind_page_object", allow_reload!: nil)
        capybara_stub.session.expects(:first).with("#kind", { minimum: 0 }).returns(kind_page_object)
        verify_element_on_parent(jon, :kind, AePageObjects::Checkbox, kind_page_object)
      end

      def test_element__is__special_widget
        special_widget = Class.new(AePageObjects::Element)

        kitty = Class.new(AePageObjects::Document) do
          element :kind, :is => special_widget
        end

        assert kitty.method_defined?(:kind)
        assert_equal [:kind], kitty.element_attributes.keys

        stub_current_window

        jon = kitty.new

        kind_page_object = stub("kind_page_object", allow_reload!: nil)
        capybara_stub.session.expects(:first).with("#kind", { minimum: 0 }).returns(kind_page_object)

        verify_element_on_parent(jon, :kind, special_widget, kind_page_object)
      end

      def test_element__is__special_widget__with_locator
        special_widget = Class.new(AePageObjects::Element)

        kitty = Class.new(AePageObjects::Document) do
          element :kind, :is => special_widget, :locator => "As If!"
        end

        assert kitty.method_defined?(:kind)
        assert_equal [:kind], kitty.element_attributes.keys

        stub_current_window

        jon = kitty.new

        kind_page_object = stub("kind_page_object", allow_reload!: nil)
        capybara_stub.session.expects(:first).with("As If!", { minimum: 0 }).returns(kind_page_object)

        verify_element_on_parent(jon, :kind, special_widget, kind_page_object)
      end

      def test_nested_element__block
        kitty = Class.new(AePageObjects::Document) do
          element :tail, :name => "tail_attributes" do
            element :color
            element :size, :name => "size_attributes" do
              element :length
              element :width

              def grow!
                "Growing!"
              end
            end
          end
        end

        verify_kitty_structure(kitty)

        stub_current_window

        jon = kitty.new

        tail_page_object = stub("tail_page_object", allow_reload!: nil)
        capybara_stub.session.expects(:first).with("#tail_attributes", { minimum: 0 }).returns(tail_page_object)

        tail = verify_element_on_parent_with_intermediary_class(jon, :tail, AePageObjects::Element, tail_page_object)

        color_page_object = stub("color_page_object", allow_reload!: nil)
        tail_page_object.expects(:first).with("#tail_attributes_color", { minimum: 0 }).returns(color_page_object)
        verify_element_on_parent(tail, :color, AePageObjects::Element, color_page_object)

        size_page_object = stub("size_page_object", allow_reload!: nil)
        tail_page_object.expects(:first).with("#tail_attributes_size_attributes", { minimum: 0 }).returns(size_page_object)
        size = verify_element_on_parent_with_intermediary_class(tail, :size, AePageObjects::Element, size_page_object)

        assert_equal "Growing!", size.grow!

        length_page_object = stub("length_page_object", allow_reload!: nil)
        size_page_object.expects(:first).with("#tail_attributes_size_attributes_length", { minimum: 0 }).returns(length_page_object)
        verify_element_on_parent(size, :length, AePageObjects::Element, length_page_object)

        width_page_object = stub("width_page_object", allow_reload!: nil)
        size_page_object.expects(:first).with("#tail_attributes_size_attributes_width", { minimum: 0 }).returns(width_page_object)
        verify_element_on_parent(size, :width, AePageObjects::Element, width_page_object)
      end

      def test_nested_element__is
        tail_class = Class.new(AePageObjects::Element) do
          element :color
          element :size, :name => "size_attributes" do
            element :length
            element :width

            def grow!
              "Growing!"
            end
          end
        end

        kitty = Class.new(AePageObjects::Document) do
          element :tail, :is => tail_class, :name => 'tail_attributes'
        end

        verify_kitty_structure(kitty)

        stub_current_window

        jon = kitty.new

        tail_page_object = stub("tail_page_object", allow_reload!: nil)
        capybara_stub.session.expects(:first).with("#tail_attributes", { minimum: 0 }).returns(tail_page_object)

        tail = verify_element_on_parent(jon, :tail, tail_class, tail_page_object)

        color_page_object = stub("color_page_object", allow_reload!: nil)
        tail_page_object.expects(:first).with("#tail_attributes_color", { minimum: 0 }).returns(color_page_object)
        verify_element_on_parent(tail, :color, AePageObjects::Element, color_page_object)

        size_page_object = stub("size_page_object", allow_reload!: nil)
        tail_page_object.expects(:first).with("#tail_attributes_size_attributes", { minimum: 0 }).returns(size_page_object)
        size = verify_element_on_parent_with_intermediary_class(tail, :size, AePageObjects::Element, size_page_object)

        assert_equal "Growing!", size.grow!

        length_page_object = stub("length_page_object", allow_reload!: nil)
        size_page_object.expects(:first).with("#tail_attributes_size_attributes_length", { minimum: 0 }).returns(length_page_object)
        verify_element_on_parent(size, :length, AePageObjects::Element, length_page_object)

        width_page_object = stub("width_page_object", allow_reload!: nil)
        size_page_object.expects(:first).with("#tail_attributes_size_attributes_width", anything).returns(width_page_object)
        verify_element_on_parent(size, :width, AePageObjects::Element, width_page_object)
      end

      def test_nested_element__is__block
        tail_base_class = Class.new(AePageObjects::Element)

        kitty = Class.new(AePageObjects::Document) do
          element :tail, :name => "tail_attributes", :is => tail_base_class do
            element :color
            element :size, :name => "size_attributes" do
              element :length
              element :width

              def grow!
                "Growing!"
              end
            end
          end
        end

        verify_kitty_structure(kitty)

        stub_current_window

        jon = kitty.new

        tail_page_object = stub("tail_page_object", allow_reload!: nil)
        capybara_stub.session.expects(:first).with("#tail_attributes", { minimum: 0 }).returns(tail_page_object)

        tail = verify_element_on_parent_with_intermediary_class(jon, :tail, tail_base_class, tail_page_object)

        color_page_object = stub("color_page_object", allow_reload!: nil)
        tail_page_object.expects(:first).with("#tail_attributes_color", { minimum: 0 }).returns(color_page_object)
        verify_element_on_parent(tail, :color, AePageObjects::Element, color_page_object)

        size_page_object = stub("size_page_object", allow_reload!: nil)
        tail_page_object.expects(:first).with("#tail_attributes_size_attributes", { minimum: 0 }).returns(size_page_object)
        size = verify_element_on_parent_with_intermediary_class(tail, :size, AePageObjects::Element, size_page_object)

        assert_equal "Growing!", size.grow!

        length_page_object = stub("length_page_object", allow_reload!: nil)
        size_page_object.expects(:first).with("#tail_attributes_size_attributes_length", { minimum: 0 }).returns(length_page_object)
        verify_element_on_parent(size, :length, AePageObjects::Element, length_page_object)

        width_page_object = stub("width_page_object", allow_reload!: nil)
        size_page_object.expects(:first).with("#tail_attributes_size_attributes_width", { minimum: 0 }).returns(width_page_object)
        verify_element_on_parent(size, :width, AePageObjects::Element, width_page_object)
      end

      def test_nested_element__locator
        kitty = Class.new(AePageObjects::Document) do
          element :tail, :locator => "what ever you want, baby", :name => 'tail_attributes' do
            element :color
            element :size, :locator => "Size", :name => 'size_attributes' do
              element :length
              element :width, :locator => "Fatness"

              def grow!
                "Growing!"
              end
            end
          end
        end

        verify_kitty_structure(kitty)

        stub_current_window

        jon = kitty.new

        tail_page_object = stub("tail_page_object", allow_reload!: nil)
        capybara_stub.session.expects(:first).with("what ever you want, baby", { minimum: 0 }).returns(tail_page_object)

        tail = verify_element_on_parent_with_intermediary_class(jon, :tail, AePageObjects::Element, tail_page_object)

        color_page_object = stub("color_page_object", allow_reload!: nil)
        tail_page_object.expects(:first).with("#tail_attributes_color", { minimum: 0 }).returns(color_page_object)
        verify_element_on_parent(tail, :color, AePageObjects::Element, color_page_object)

        size_page_object = stub("size_page_object", allow_reload!: nil)
        tail_page_object.expects(:first).with("Size", { minimum: 0 }).returns(size_page_object)
        size = verify_element_on_parent_with_intermediary_class(tail, :size, AePageObjects::Element, size_page_object)

        assert_equal "Growing!", size.grow!

        length_page_object = stub("length_page_object", allow_reload!: nil)
        size_page_object.expects(:first).with("#tail_attributes_size_attributes_length", { minimum: 0 }).returns(length_page_object)
        verify_element_on_parent(size, :length, AePageObjects::Element, length_page_object)

        width_page_object = stub("width_page_object", allow_reload!: nil)
        size_page_object.expects(:first).with("Fatness", { minimum: 0 }).returns(width_page_object)
        verify_element_on_parent(size, :width, AePageObjects::Element, width_page_object)
      end

      def test_nested_element__locator__proc
        kitty = Class.new(AePageObjects::Document) do
          element :tail, :name => 'tail_attributes' do
            element :color
            element :size, :name => 'size_attributes' do
              element :length
              element :width, :locator => Proc.new { parent.page_local_context }

              def grow!
                "Growing!"
              end

              def page_local_context; end
            end
          end
        end

        verify_kitty_structure(kitty)

        stub_current_window

        jon = kitty.new

        tail_page_object = stub("tail_page_object", allow_reload!: nil)
        capybara_stub.session.expects(:first).with("#tail_attributes", { minimum: 0 }).returns(tail_page_object)

        tail = verify_element_on_parent_with_intermediary_class(jon, :tail, AePageObjects::Element, tail_page_object)

        color_page_object = stub("color_page_object", allow_reload!: nil)
        tail_page_object.expects(:first).with("#tail_attributes_color", { minimum: 0 }).returns(color_page_object)
        verify_element_on_parent(tail, :color, AePageObjects::Element, color_page_object)

        size_page_object = stub("size_page_object", allow_reload!: nil)
        tail_page_object.expects(:first).with("#tail_attributes_size_attributes", { minimum: 0 }).returns(size_page_object)
        size = verify_element_on_parent_with_intermediary_class(tail, :size, AePageObjects::Element, size_page_object)

        assert_equal "Growing!", size.grow!

        length_page_object = stub("length_page_object", allow_reload!: nil)
        size_page_object.expects(:first).with("#tail_attributes_size_attributes_length", { minimum: 0 }).returns(length_page_object)
        verify_element_on_parent(size, :length, AePageObjects::Element, length_page_object)

        size.expects(:page_local_context).returns("hello")

        width_page_object = stub("width_page_object", allow_reload!: nil)
        size_page_object.expects(:first).with("hello", { minimum: 0 }).returns(width_page_object)
        verify_element_on_parent(size, :width, AePageObjects::Element, width_page_object)
      end

    private

      def verify_kitty_structure(kitty_class)
        assert_equal [:tail], kitty_class.element_attributes.keys
        assert_equal [:color, :size], kitty_class.element_attributes[:tail].element_attributes.keys.sort

        size_class = kitty_class.element_attributes[:tail].element_attributes[:size]
        assert_equal [:length, :width], size_class.element_attributes.keys.sort
        assert_include size_class.instance_methods(false).map(&:to_s), "grow!"
      end
    end
  end
end

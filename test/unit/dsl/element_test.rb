require 'unit_helper'

module AePageObjects
  module Dsl
    class ElementTest < Test::Unit::TestCase
      def test_element__basic
        kitty = ::AePageObjects::Document.new_subclass do
          element :kind
        end

        assert kitty.method_defined?(:kind)
        assert_sets_equal [:kind], kitty.element_attributes.keys
      
        document_stub = mock
        Capybara.stubs(:current_session).returns(document_stub)

        jon = kitty.new
      
        kind_page_object = mock
        document_stub.expects(:find).with("#kind").returns(kind_page_object)
        verify_field(jon, :kind, ::AePageObjects::Element, kind_page_object)
      end
      
      def test_element__accessor_yields_to_block
        kitty = ::AePageObjects::Document.new_subclass do
          element :kind
        end

        assert kitty.method_defined?(:kind)
        assert_sets_equal [:kind], kitty.element_attributes.keys
      
        document_stub = mock
        Capybara.stubs(:current_session).returns(document_stub)

        jon = kitty.new
        
        kind_page_object = mock
        document_stub.expects(:find).with("#kind").returns(kind_page_object)

        kind_in_block = nil
        kind = jon.kind do |kind|
          kind_in_block = kind
          "hello"
        end
        
        assert_false kind_in_block.is_a?(AePageObjects::ElementProxy)
        assert kind_in_block.is_a?(AePageObjects::Element)

        assert kind.is_a?(AePageObjects::ElementProxy)
        assert kind.is_a?(AePageObjects::Element)
        
        assert_equal kind, kind_in_block
      end
    
      def test_element__locator
        kitty = ::AePageObjects::Document.new_subclass do
          element :kind, :locator => "Kind Homie"
        end
        
        assert kitty.method_defined?(:kind)
        assert_sets_equal [:kind], kitty.element_attributes.keys
      
        document_stub = mock
        Capybara.stubs(:current_session).returns(document_stub)

        jon = kitty.new
      
        kind_page_object = mock
        document_stub.expects(:find).with("Kind Homie").returns(kind_page_object)
        verify_field(jon, :kind, ::AePageObjects::Element, kind_page_object)
      end
    
      def test_element__locator__proc
        kitty = ::AePageObjects::Document.new_subclass do
          element :kind, :locator => Proc.new { parent.page_local_context }
        end
        
        assert kitty.method_defined?(:kind)
        assert_sets_equal [:kind], kitty.element_attributes.keys
      
        document_stub = mock
        Capybara.stubs(:current_session).returns(document_stub)

        jon = kitty.new
        jon.expects(:page_local_context).returns("hello")
      
        kind_page_object = mock
        document_stub.expects(:find).with("hello").returns(kind_page_object)
        verify_field(jon, :kind, ::AePageObjects::Element, kind_page_object)
      end
    
      def test_element__is__select
        kitty = ::AePageObjects::Document.new_subclass do
          element :kind, :is => ::AePageObjects::Select
        end
        
        assert kitty.method_defined?(:kind)
        assert_sets_equal [:kind], kitty.element_attributes.keys
      
        document_stub = mock
        Capybara.stubs(:current_session).returns(document_stub)

        jon = kitty.new
      
        kind_page_object = mock
        document_stub.expects(:find).with("#kind").returns(kind_page_object)
        verify_field(jon, :kind, ::AePageObjects::Select, kind_page_object)
      end
    
      def test_element__is__checkbox
        kitty = ::AePageObjects::Document.new_subclass do
          element :kind, :is => ::AePageObjects::Checkbox
        end
        
        assert kitty.method_defined?(:kind)
        assert_sets_equal [:kind], kitty.element_attributes.keys
      
        document_stub = mock
        Capybara.stubs(:current_session).returns(document_stub)

        jon = kitty.new
      
        kind_page_object = mock
        document_stub.expects(:find).with("#kind").returns(kind_page_object)
        verify_field(jon, :kind, ::AePageObjects::Checkbox, kind_page_object)
      end
    
      def test_element__is__special_widget
        special_widget = ::AePageObjects::Element.new_subclass
      
        kitty = ::AePageObjects::Document.new_subclass do
          element :kind, :is => special_widget
        end
        
        assert kitty.method_defined?(:kind)
        assert_sets_equal [:kind], kitty.element_attributes.keys
      
        document_stub = mock
        Capybara.stubs(:current_session).returns(document_stub)

        jon = kitty.new
      
        kind_page_object = mock
        document_stub.expects(:find).with("#kind").returns(kind_page_object)
      
        verify_field(jon, :kind, special_widget, kind_page_object)
      end
    
      def test_element__is__special_widget__with_locator
        special_widget = ::AePageObjects::Element.new_subclass
      
        kitty = ::AePageObjects::Document.new_subclass do
          element :kind, :is => special_widget, :locator => "As If!"
        end
        
        assert kitty.method_defined?(:kind)
        assert_sets_equal [:kind], kitty.element_attributes.keys

        document_stub = mock
        Capybara.stubs(:current_session).returns(document_stub)

        jon = kitty.new
      
        kind_page_object = mock
        document_stub.expects(:find).with("As If!").returns(kind_page_object)
      
        verify_field(jon, :kind, special_widget, kind_page_object)
      end
      
      def test_nested_element__block
        kitty = ::AePageObjects::Document.new_subclass do
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

        document_stub = mock
        Capybara.stubs(:current_session).returns(document_stub)

        jon = kitty.new

        tail_page_object = mock
        document_stub.expects(:find).with("#tail_attributes").returns(tail_page_object)

        tail = verify_field_with_intermediary_class(jon, :tail, ::AePageObjects::Element, tail_page_object)

        color_page_object = mock
        tail_page_object.expects(:find).with("#tail_attributes_color").returns(color_page_object)
        verify_field(tail, :color, ::AePageObjects::Element, color_page_object)

        size_page_object = mock
        tail_page_object.expects(:find).with("#tail_attributes_size_attributes").returns(size_page_object)
        size = verify_field_with_intermediary_class(tail, :size, ::AePageObjects::Element, size_page_object)

        assert_equal "Growing!", size.grow!

        length_page_object = mock
        size_page_object.expects(:find).with("#tail_attributes_size_attributes_length").returns(length_page_object)
        verify_field(size, :length, ::AePageObjects::Element, length_page_object)

        width_page_object = mock
        size_page_object.expects(:find).with("#tail_attributes_size_attributes_width").returns(width_page_object)
        verify_field(size, :width, ::AePageObjects::Element, width_page_object)
      end

      def test_nested_element__is
        tail_class = ::AePageObjects::Element.new_subclass do
          element :color
          element :size, :name => "size_attributes" do
            element :length
            element :width

            def grow!
              "Growing!"
            end
          end
        end

        kitty = ::AePageObjects::Document.new_subclass do
          element :tail, :is => tail_class, :name => 'tail_attributes'
        end

        verify_kitty_structure(kitty)

        document_stub = mock
        Capybara.stubs(:current_session).returns(document_stub)

        jon = kitty.new

        tail_page_object = mock
        document_stub.expects(:find).with("#tail_attributes").returns(tail_page_object)

        tail = verify_field(jon, :tail, tail_class, tail_page_object)

        color_page_object = mock
        tail_page_object.expects(:find).with("#tail_attributes_color").returns(color_page_object)
        verify_field(tail, :color, ::AePageObjects::Element, color_page_object)

        size_page_object = mock
        tail_page_object.expects(:find).with("#tail_attributes_size_attributes").returns(size_page_object)
        size = verify_field_with_intermediary_class(tail, :size, ::AePageObjects::Element, size_page_object)

        assert_equal "Growing!", size.grow!

        length_page_object = mock
        size_page_object.expects(:find).with("#tail_attributes_size_attributes_length").returns(length_page_object)
        verify_field(size, :length, ::AePageObjects::Element, length_page_object)

        width_page_object = mock
        size_page_object.expects(:find).with("#tail_attributes_size_attributes_width", anything).returns(width_page_object)
        verify_field(size, :width, ::AePageObjects::Element, width_page_object)
      end

      def test_nested_element__is__block
        tail_base_class = ::AePageObjects::Element.new_subclass
        
        kitty = ::AePageObjects::Document.new_subclass do
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

        document_stub = mock
        Capybara.stubs(:current_session).returns(document_stub)

        jon = kitty.new

        tail_page_object = mock
        document_stub.expects(:find).with("#tail_attributes").returns(tail_page_object)

        tail = verify_field_with_intermediary_class(jon, :tail, tail_base_class, tail_page_object)

        color_page_object = mock
        tail_page_object.expects(:find).with("#tail_attributes_color").returns(color_page_object)
        verify_field(tail, :color, ::AePageObjects::Element, color_page_object)

        size_page_object = mock
        tail_page_object.expects(:find).with("#tail_attributes_size_attributes").returns(size_page_object)
        size = verify_field_with_intermediary_class(tail, :size, ::AePageObjects::Element, size_page_object)

        assert_equal "Growing!", size.grow!

        length_page_object = mock
        size_page_object.expects(:find).with("#tail_attributes_size_attributes_length").returns(length_page_object)
        verify_field(size, :length, ::AePageObjects::Element, length_page_object)

        width_page_object = mock
        size_page_object.expects(:find).with("#tail_attributes_size_attributes_width").returns(width_page_object)
        verify_field(size, :width, ::AePageObjects::Element, width_page_object)
      end

      def test_nested_element__locator
        kitty = ::AePageObjects::Document.new_subclass do
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

        document_stub = mock
        Capybara.stubs(:current_session).returns(document_stub)

        jon = kitty.new

        tail_page_object = mock
        document_stub.expects(:find).with("what ever you want, baby").returns(tail_page_object)

        tail = verify_field_with_intermediary_class(jon, :tail, ::AePageObjects::Element, tail_page_object)

        color_page_object = mock
        tail_page_object.expects(:find).with("#tail_attributes_color").returns(color_page_object)
        verify_field(tail, :color, ::AePageObjects::Element, color_page_object)

        size_page_object = mock
        tail_page_object.expects(:find).with("Size").returns(size_page_object)
        size = verify_field_with_intermediary_class(tail, :size, ::AePageObjects::Element, size_page_object)

        assert_equal "Growing!", size.grow!

        length_page_object = mock
        size_page_object.expects(:find).with("#tail_attributes_size_attributes_length").returns(length_page_object)
        verify_field(size, :length, ::AePageObjects::Element, length_page_object)

        width_page_object = mock
        size_page_object.expects(:find).with("Fatness").returns(width_page_object)
        verify_field(size, :width, ::AePageObjects::Element, width_page_object)
      end

      def test_nested_element__locator__proc
        kitty = ::AePageObjects::Document.new_subclass do
          element :tail, :name => 'tail_attributes' do
            element :color
            element :size, :name => 'size_attributes' do
              element :length
              element :width, :locator => Proc.new { parent.page_local_context }

              def grow!
                "Growing!"
              end
            end
          end
        end

        verify_kitty_structure(kitty)

        document_stub = mock
        Capybara.stubs(:current_session).returns(document_stub)

        jon = kitty.new

        tail_page_object = mock
        document_stub.expects(:find).with("#tail_attributes").returns(tail_page_object)

        tail = verify_field_with_intermediary_class(jon, :tail, ::AePageObjects::Element, tail_page_object)

        color_page_object = mock
        tail_page_object.expects(:find).with("#tail_attributes_color").returns(color_page_object)
        verify_field(tail, :color, ::AePageObjects::Element, color_page_object)

        size_page_object = mock
        tail_page_object.expects(:find).with("#tail_attributes_size_attributes").returns(size_page_object)
        size = verify_field_with_intermediary_class(tail, :size, ::AePageObjects::Element, size_page_object)

        assert_equal "Growing!", size.grow!

        length_page_object = mock
        size_page_object.expects(:find).with("#tail_attributes_size_attributes_length").returns(length_page_object)
        verify_field(size, :length, ::AePageObjects::Element, length_page_object)

        size.expects(:page_local_context).returns("hello")

        width_page_object = mock
        size_page_object.expects(:find).with("hello").returns(width_page_object)
        verify_field(size, :width, ::AePageObjects::Element, width_page_object)
      end

    private

      def verify_kitty_structure(kitty_class)
        assert_sets_equal [:tail], kitty_class.element_attributes.keys
        assert_sets_equal [:color, :size], kitty_class.element_attributes[:tail].element_attributes.keys

        size_class = kitty_class.element_attributes[:tail].element_attributes[:size]
        assert_sets_equal [:length, :width], size_class.element_attributes.keys
        assert_include size_class.instance_methods(false).map(&:to_s), "grow!"
      end
    end
  end
end

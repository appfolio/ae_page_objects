require 'unit_helper'

module AePageObjects
  module AttributeMethods
    class NodeTest < ActiveSupport::TestCase
    
      def test_element__basic
        kitty = ::AePageObjects::Document.new_subclass do
          element :kind
        end

        assert kitty.method_defined?(:kind)
        assert_sets_equal [:kind], kitty.element_attributes.keys
      
        document_stub = mock
        jon = kitty.new(document_stub)
      
        kind_page_object = mock
        document_stub.expects(:find).with("#kind").returns(kind_page_object)
        verify_field(jon, :kind, ::AePageObjects::Element, kind_page_object)
      rescue => e
        puts e.backtrace.join("\n")
        raise e
      end
      
      def test_element__accessor_yields_to_block
        kitty = ::AePageObjects::Document.new_subclass do
          element :kind
        end

        assert kitty.method_defined?(:kind)
        assert_sets_equal [:kind], kitty.element_attributes.keys
      
        document_stub = mock
        jon = kitty.new(document_stub)
        
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
      rescue => e
        puts e.backtrace.join("\n")
        raise e
      end
    
      def test_element__locator
        kitty = ::AePageObjects::Document.new_subclass do
          element :kind, :locator => "Kind Homie"
        end
        
        assert kitty.method_defined?(:kind)
        assert_sets_equal [:kind], kitty.element_attributes.keys
      
        document_stub = mock
        jon = kitty.new(document_stub)
      
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
        jon = kitty.new(document_stub)
        jon.expects(:page_local_context).returns("hello")
      
        kind_page_object = mock
        document_stub.expects(:find).with("hello").returns(kind_page_object)
        verify_field(jon, :kind, ::AePageObjects::Element, kind_page_object)
      end
    
      def test_element__as__select
        kitty = ::AePageObjects::Document.new_subclass do
          element :kind, :is => ::AePageObjects::Select
        end
        
        assert kitty.method_defined?(:kind)
        assert_sets_equal [:kind], kitty.element_attributes.keys
      
        document_stub = mock
        jon = kitty.new(document_stub)
      
        kind_page_object = mock
        document_stub.expects(:find).with("#kind").returns(kind_page_object)
        verify_field(jon, :kind, ::AePageObjects::Select, kind_page_object)
      end
    
      def test_element__as__checkbox
        kitty = ::AePageObjects::Document.new_subclass do
          element :kind, :is => ::AePageObjects::Checkbox
        end
        
        assert kitty.method_defined?(:kind)
        assert_sets_equal [:kind], kitty.element_attributes.keys
      
        document_stub = mock
        jon = kitty.new(document_stub)
      
        kind_page_object = mock
        document_stub.expects(:find).with("#kind").returns(kind_page_object)
        verify_field(jon, :kind, ::AePageObjects::Checkbox, kind_page_object)
      end
    
      def test_element__as__special_widget
        special_widget = ::AePageObjects::Element.new_subclass
      
        kitty = ::AePageObjects::Document.new_subclass do
          element :kind, :is => special_widget
        end
        
        assert kitty.method_defined?(:kind)
        assert_sets_equal [:kind], kitty.element_attributes.keys
      
        document_stub = mock
        jon = kitty.new(document_stub)
      
        kind_page_object = mock
        document_stub.expects(:find).with("#kind").returns(kind_page_object)
      
        verify_field(jon, :kind, special_widget, kind_page_object)
      end
    
      def test_element__as__special_widget__with_locator
        special_widget = ::AePageObjects::Element.new_subclass
      
        kitty = ::AePageObjects::Document.new_subclass do
          element :kind, :is => special_widget, :locator => "As If!"
        end
        
        assert kitty.method_defined?(:kind)
        assert_sets_equal [:kind], kitty.element_attributes.keys
      
        document_stub = mock
        jon = kitty.new(document_stub)
      
        kind_page_object = mock
        document_stub.expects(:find).with("As If!").returns(kind_page_object)
      
        verify_field(jon, :kind, special_widget, kind_page_object)
      end
    end
  end
end

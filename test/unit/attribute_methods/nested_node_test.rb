require 'unit_helper'

module AePageObjects
  module AttributeMethods
    class NestedNodeTest < ActiveSupport::TestCase
    
      def test_nested_node__block
        kitty = ::AePageObjects::Document.new_subclass do
          node :tail do
            node :color
            node :size do
              node :length
              node :width
              
              def grow!
                "Growing!"
              end
            end
          end
        end
        
        verify_kitty_structure(kitty)
      
        document_stub = mock
        jon = kitty.new(document_stub)
      
        tail_page_object = mock
        document_stub.expects(:find).with("#tail_attributes").returns(tail_page_object)
      
        tail = verify_field_with_intermediary_class(jon, :tail, ::AePageObjects::HasOne, tail_page_object)

        color_page_object = mock
        tail_page_object.expects(:find).with("#tail_attributes_color").returns(color_page_object)
        verify_field(tail, :color, ::AePageObjects::Element, color_page_object)
        
        size_page_object = mock
        tail_page_object.expects(:find).with("#tail_attributes_size_attributes").returns(size_page_object)
        size = verify_field_with_intermediary_class(tail, :size, ::AePageObjects::HasOne, size_page_object)
        
        assert_equal "Growing!", size.grow!
        
        length_page_object = mock
        size_page_object.expects(:find).with("#tail_attributes_size_attributes_length").returns(length_page_object)
        verify_field(size, :length, ::AePageObjects::Element, length_page_object)
        
        width_page_object = mock
        size_page_object.expects(:find).with("#tail_attributes_size_attributes_width").returns(width_page_object)
        verify_field(size, :width, ::AePageObjects::Element, width_page_object)
      rescue => e
        puts e.backtrace.join("\n")
        raise e
      end
      
      def test_nested_node__as
        tail_class = ::AePageObjects::HasOne.new_subclass do
          node :color
          node :size do
            node :length
            node :width
            
            def grow!
              "Growing!"
            end
          end
        end
        
        kitty = ::AePageObjects::Document.new_subclass do
          node :tail, :as => tail_class
        end
        
        verify_kitty_structure(kitty)
      
        document_stub = mock
        jon = kitty.new(document_stub)
      
        tail_page_object = mock
        document_stub.expects(:find).with("#tail_attributes").returns(tail_page_object)
      
        tail = verify_field(jon, :tail, tail_class, tail_page_object)

        color_page_object = mock
        tail_page_object.expects(:find).with("#tail_attributes_color").returns(color_page_object)
        verify_field(tail, :color, ::AePageObjects::Element, color_page_object)
        
        size_page_object = mock
        tail_page_object.expects(:find).with("#tail_attributes_size_attributes").returns(size_page_object)
        size = verify_field_with_intermediary_class(tail, :size, ::AePageObjects::HasOne, size_page_object)
        
        assert_equal "Growing!", size.grow!
        
        length_page_object = mock
        size_page_object.expects(:find).with("#tail_attributes_size_attributes_length").returns(length_page_object)
        verify_field(size, :length, ::AePageObjects::Element, length_page_object)
        
        width_page_object = mock
        size_page_object.expects(:find).with("#tail_attributes_size_attributes_width", anything).returns(width_page_object)
        verify_field(size, :width, ::AePageObjects::Element, width_page_object)
      end
    
      def test_nested_node__as_block_mutual_exclusion
        assert_raises ArgumentError do
          kitty = ::AePageObjects::Document.new_subclass do
            node :tail, :as => :select do
              raise "You will never see this"
            end
          end
        end
      end

      def test_nested_node__locator
        kitty = ::AePageObjects::Document.new_subclass do
          node :tail, :locator => "what ever you want, baby" do
            node :color
            node :size, :locator => "Size" do
              node :length
              node :width, :locator => "Fatness"
              
              def grow!
                "Growing!"
              end
            end
          end
        end
        
        verify_kitty_structure(kitty)
      
        document_stub = mock
        jon = kitty.new(document_stub)
        
        tail_page_object = mock
        document_stub.expects(:find).with("what ever you want, baby").returns(tail_page_object)
      
        tail = verify_field_with_intermediary_class(jon, :tail, ::AePageObjects::HasOne, tail_page_object)

        color_page_object = mock
        tail_page_object.expects(:find).with("#tail_attributes_color").returns(color_page_object)
        verify_field(tail, :color, ::AePageObjects::Element, color_page_object)
        
        size_page_object = mock
        tail_page_object.expects(:find).with("Size").returns(size_page_object)
        size = verify_field_with_intermediary_class(tail, :size, ::AePageObjects::HasOne, size_page_object)
        
        assert_equal "Growing!", size.grow!
        
        length_page_object = mock
        size_page_object.expects(:find).with("#tail_attributes_size_attributes_length").returns(length_page_object)
        verify_field(size, :length, ::AePageObjects::Element, length_page_object)
        
        width_page_object = mock
        size_page_object.expects(:find).with("Fatness").returns(width_page_object)
        verify_field(size, :width, ::AePageObjects::Element, width_page_object)
      end
          
      def test_nested_node__locator__proc
        kitty = ::AePageObjects::Document.new_subclass do
          node :tail  do
            node :color
            node :size do
              node :length
              node :width, :locator => Proc.new { parent.page_local_context }
              
              def grow!
                "Growing!"
              end
            end
          end
        end
        
        verify_kitty_structure(kitty)
      
        document_stub = mock
        jon = kitty.new(document_stub)
      
        tail_page_object = mock
        document_stub.expects(:find).with("#tail_attributes").returns(tail_page_object)
      
        tail = verify_field_with_intermediary_class(jon, :tail, ::AePageObjects::HasOne, tail_page_object)

        color_page_object = mock
        tail_page_object.expects(:find).with("#tail_attributes_color").returns(color_page_object)
        verify_field(tail, :color, ::AePageObjects::Element, color_page_object)
        
        size_page_object = mock
        tail_page_object.expects(:find).with("#tail_attributes_size_attributes").returns(size_page_object)
        size = verify_field_with_intermediary_class(tail, :size, ::AePageObjects::HasOne, size_page_object)
        
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
        assert_sets_equal [:tail], kitty_class.node_attributes.keys
        assert_sets_equal [:color, :size], kitty_class.node_attributes[:tail].node_attributes.keys
        
        size_class = kitty_class.node_attributes[:tail].node_attributes[:size]
        assert_sets_equal [:length, :width], size_class.node_attributes.keys
        assert_include size_class.instance_methods(false), "grow!"
      end
    end
  end
end
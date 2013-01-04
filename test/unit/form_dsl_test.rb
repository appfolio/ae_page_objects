require 'unit_helper'

module AePageObjects
  class FormDslTest < ActiveSupport::TestCase
  
    def test_form
      kitty_class = ::AePageObjects::Document.new_subclass do
        form_for "kitty" do
          element :name
          element :age
          
          element :owner do
            element :name
          end
          
          collection :past_lives do
            element :died_at
          end
        end
      end
      
      verify_kitty_structure(kitty_class)
      
      document_stub = mock
      jon = kitty_class.new(document_stub)
      
      verify_top_level_form_field(jon, :name, document_stub)
      verify_top_level_form_field(jon, :age, document_stub)
      
      verify_top_level_form_field(jon, :owner, document_stub) do |field_xpath, field_page_object|
        document_stub.stubs(:find).with("#kitty_owner_attributes", anything).returns(field_page_object)
      end
      
      verify_top_level_form_field(jon, :past_lives, document_stub) do |field_xpath, field_page_object|
        document_stub.stubs(:find).with("#kitty_past_lives_attributes", anything).returns(field_page_object)
      end
    end
  
    def test_form__using
      kitty_class = ::AePageObjects::Document.new_subclass do
        form_for "kitty", :name => "the_kat" do
          element :name
          element :age
          
          element :owner do
            element :name
          end
          
          collection :past_lives do
            element :died_at
          end
        end
      end
      
      verify_kitty_structure(kitty_class)
      
      document_stub = mock
      jon = kitty_class.new(document_stub)
      
      verify_top_level_form_field(jon, :name, document_stub) do |field_xpath, field_page_object|
        document_stub.stubs(:find).with("#the_kat_name").returns(field_page_object)
      end
      
      verify_top_level_form_field(jon, :age, document_stub) do |field_xpath, field_page_object|
        document_stub.stubs(:find).with("#the_kat_age").returns(field_page_object)
      end
      
      verify_top_level_form_field(jon, :owner, document_stub) do |field_xpath, field_page_object|
        document_stub.stubs(:find).with("#the_kat_owner_attributes", anything).returns(field_page_object)
      end
      
      verify_top_level_form_field(jon, :past_lives, document_stub) do |field_xpath, field_page_object|
        document_stub.stubs(:find).with("#the_kat_past_lives_attributes", anything).returns(field_page_object)
      end
    rescue => e
      puts e.backtrace.join("\n")
      raise e
    end  
    
    def test_form__using__locator
      kitty_class = ::AePageObjects::Document.new_subclass do
        form_for "kitty", :locator => [:css, "#my_kitty_box"], :name => "the_kat" do
          element :name
          element :age
          
          element :owner do
            element :name
          end

          collection :past_lives do
            element :died_at
          end
        end
      end
      
      verify_kitty_structure(kitty_class)
      
      document_stub = mock
      jon = kitty_class.new(document_stub)
      
      kitty_box_page_stub = mock
      
      document_stub.expects(:find).with(:css, '#my_kitty_box').returns(kitty_box_page_stub).times(2)
      verify_top_level_form_field(jon, :name, kitty_box_page_stub) do |field_xpath, field_page_object, times|
        kitty_box_page_stub.stubs(:find).with("#the_kat_name").returns(field_page_object)
      end
      
      document_stub.expects(:find).with(:css, '#my_kitty_box').returns(kitty_box_page_stub).times(2)
      verify_top_level_form_field(jon, :age, kitty_box_page_stub) do |field_xpath, field_page_object|
        kitty_box_page_stub.stubs(:find).with("#the_kat_age").returns(field_page_object)
      end
      
      document_stub.expects(:find).with(:css, '#my_kitty_box').returns(kitty_box_page_stub).times(2)
      verify_top_level_form_field(jon, :owner, kitty_box_page_stub) do |field_xpath, field_page_object|
        kitty_box_page_stub.stubs(:find).with("#the_kat_owner_attributes", anything).returns(field_page_object)
      end
      
      document_stub.expects(:find).with(:css, '#my_kitty_box').returns(kitty_box_page_stub).times(2)
      verify_top_level_form_field(jon, :past_lives, kitty_box_page_stub) do |field_xpath, field_page_object|
        kitty_box_page_stub.stubs(:find).with("#the_kat_past_lives_attributes", anything).returns(field_page_object)
      end
    rescue => e
      puts e.backtrace.join("\n")
      raise e
    end

  private
    
    def verify_top_level_form_field(kitty, field_method, document_stub, &prepare_for_field_reference)
      prepare_for_field_reference ||= Proc.new do |field_xpath, field_page_object|
        document_stub.stubs(:find).with("#kitty_#{field_method}").returns(field_page_object)
      end
      
      form = verify_field(kitty, :kitty, kitty.class.element_attributes[:kitty], document_stub)

      field_xpath = "kitty_#{field_method}_xpath"
      field_page_object = mock
      prepare_for_field_reference.call(field_xpath, field_page_object)
      expected_field_type = form.class.element_attributes[field_method]
      field_node = verify_field(form, field_method, expected_field_type, field_page_object)

      prepare_for_field_reference.call(field_xpath, field_page_object)
      assert_nodes_equal field_node, kitty.send(field_method)
    end

    def verify_kitty_structure(kitty_class)
      assert_sets_equal [:kitty, :name, :age, :owner, :past_lives], kitty_class.element_attributes.keys
      assert_sets_equal [:name, :age, :owner, :past_lives], kitty_class.element_attributes[:kitty].element_attributes.keys
      
      owner_class = kitty_class.element_attributes[:kitty].element_attributes[:owner]
      assert_sets_equal [:name], owner_class.element_attributes.keys
      
      past_lives_item_class = kitty_class.element_attributes[:kitty].element_attributes[:past_lives].item_class
      assert_sets_equal [:died_at], past_lives_item_class.element_attributes.keys
      
      assert_sets_equal ["kitty", "owner", "age", "name", "past_lives"].map(&:to_sym), kitty_class.public_instance_methods(false).map(&:to_sym)
    end
  end
end

require 'unit_helper'

module AePageObjects
  class FormDslTest < AePageObjectsTestCase

    def test_form
      kitty_class = Class.new(AePageObjects::Document) do
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

      stub_current_window

      jon = kitty_class.new

      verify_top_level_form_field(jon, :name, capybara_stub.session)
      verify_top_level_form_field(jon, :age, capybara_stub.session)

      verify_top_level_form_field(jon, :owner, capybara_stub.session) do |field_xpath, field_page_object|
        capybara_stub.session.stubs(:first).with("#kitty_owner", anything).returns(field_page_object)
      end

      verify_top_level_form_field(jon, :past_lives, capybara_stub.session) do |field_xpath, field_page_object|
        capybara_stub.session.stubs(:first).with("#kitty_past_lives", anything).returns(field_page_object)
      end
    end

    def test_form__using
      kitty_class = Class.new(AePageObjects::Document) do
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

      stub_current_window

      jon = kitty_class.new

      verify_top_level_form_field(jon, :name, capybara_stub.session) do |field_xpath, field_page_object|
        capybara_stub.session.stubs(:first).with("#the_kat_name", { minimum: 0 }).returns(field_page_object)
      end

      verify_top_level_form_field(jon, :age, capybara_stub.session) do |field_xpath, field_page_object|
        capybara_stub.session.stubs(:first).with("#the_kat_age", { minimum: 0 }).returns(field_page_object)
      end

      verify_top_level_form_field(jon, :owner, capybara_stub.session) do |field_xpath, field_page_object|
        capybara_stub.session.stubs(:first).with("#the_kat_owner", anything).returns(field_page_object)
      end

      verify_top_level_form_field(jon, :past_lives, capybara_stub.session) do |field_xpath, field_page_object|
        capybara_stub.session.stubs(:first).with("#the_kat_past_lives", anything).returns(field_page_object)
      end
    end

    def test_form__using__locator
      kitty_class = Class.new(AePageObjects::Document) do
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

      stub_current_window

      jon = kitty_class.new

      kitty_box_page_stub = stub(allow_reload!: nil)

      capybara_stub.session.expects(:first).with(:css, '#my_kitty_box', { minimum: 0 }).returns(kitty_box_page_stub).times(2)
      verify_top_level_form_field(jon, :name, kitty_box_page_stub) do |field_xpath, field_page_object, times|
        kitty_box_page_stub.stubs(:first).with("#the_kat_name", { minimum: 0 }).returns(field_page_object)
      end

      capybara_stub.session.expects(:first).with(:css, '#my_kitty_box', { minimum: 0 }).returns(kitty_box_page_stub).times(2)
      verify_top_level_form_field(jon, :age, kitty_box_page_stub) do |field_xpath, field_page_object|
        kitty_box_page_stub.stubs(:first).with("#the_kat_age", { minimum: 0 }).returns(field_page_object)
      end

      capybara_stub.session.expects(:first).with(:css, '#my_kitty_box', { minimum: 0 }).returns(kitty_box_page_stub).times(2)
      verify_top_level_form_field(jon, :owner, kitty_box_page_stub) do |field_xpath, field_page_object|
        kitty_box_page_stub.stubs(:first).with("#the_kat_owner", anything).returns(field_page_object)
      end

      capybara_stub.session.expects(:first).with(:css, '#my_kitty_box', { minimum: 0 }).returns(kitty_box_page_stub).times(2)
      verify_top_level_form_field(jon, :past_lives, kitty_box_page_stub) do |field_xpath, field_page_object|
        kitty_box_page_stub.stubs(:first).with("#the_kat_past_lives", anything).returns(field_page_object)
      end
    end

  private

    def verify_top_level_form_field(kitty, field_method, document_stub, &prepare_for_field_reference)
      prepare_for_field_reference ||= Proc.new do |field_xpath, field_page_object|
        document_stub.stubs(:first).with("#kitty_#{field_method}", { minimum: 0 }).returns(field_page_object)
      end

      form = verify_element_on_parent(kitty, :kitty, kitty.class.element_attributes[:kitty], document_stub)

      field_xpath = "kitty_#{field_method}_xpath"
      field_page_object = stub(allow_reload!: nil)
      prepare_for_field_reference.call(field_xpath, field_page_object)
      expected_field_type = form.class.element_attributes[field_method]
      field_node = verify_element_on_parent(form, field_method, expected_field_type, field_page_object)

      prepare_for_field_reference.call(field_xpath, field_page_object)
      assert_nodes_equal field_node, kitty.send(field_method)
    end

    def verify_kitty_structure(kitty_class)
      assert_equal [:age, :kitty, :name, :owner, :past_lives], kitty_class.element_attributes.keys.sort
      assert_equal [:age, :name, :owner, :past_lives], kitty_class.element_attributes[:kitty].element_attributes.keys.sort

      owner_class = kitty_class.element_attributes[:kitty].element_attributes[:owner]
      assert_equal [:name], owner_class.element_attributes.keys

      past_lives_item_class = kitty_class.element_attributes[:kitty].element_attributes[:past_lives].item_class
      assert_equal [:died_at], past_lives_item_class.element_attributes.keys

      assert_equal [:age, :kitty, :name, :owner, :past_lives], kitty_class.public_instance_methods(false).map(&:to_sym).sort
    end
  end
end

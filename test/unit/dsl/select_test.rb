require 'unit_helper'

module AePageObjects
  module Dsl
    class SelectTest < Test::Unit::TestCase

      attr_reader :document

      def setup
        stub_current_window
        @document = document_class.new
      end

      def test_element
        assert document_class.method_defined?(:select)
        assert_sets_equal [:select], document_class.element_attributes.keys

        capybara_node = mock
        capybara_stub.session.expects(:find).with("#select").returns(capybara_node)
        verify_field(document, :select, ::AePageObjects::Select, capybara_node)
      end

      def test_set
        capybara_node = mock
        capybara_stub.session.expects(:find).with("#select").returns(capybara_node)
        capybara_node.expects(:select).with('value')
        document.select.set('value')
      end

      def test_options
        capybara_select_node = mock
        capybara_stub.session.expects(:find).with("#select").returns(capybara_select_node)
        capybara_select_node.expects(:find).with(:xpath, '.').returns(capybara_select_node)

        options = document.select.options

        assert options.class.ancestors.include? ::AePageObjects::Collection
        assert_equal capybara_select_node, options.node
        assert_equal 'option', options.item_locator
      end

      def test_selected_option
        capybara_select_node = mock
        selected_option = mock(:value => "I'm selected")
        unselected_option = mock(:value => 'not me')

        capybara_stub.session.expects(:find).with("#select").returns(capybara_select_node)
        select = document.select

        select.expects(:options).returns([unselected_option, selected_option])
        select.expects(:value).twice.returns("I'm selected")

        assert_equal selected_option, select.selected_option
      end

      private

      def document_class
        Class.new(AePageObjects::Document) do
          element :select, :is => ::AePageObjects::Select
        end
      end

    end
  end
end


require 'unit_helper'

module AePageObjects
  class SelectTest < Test::Unit::TestCase

    def setup
      super

      parent_node = mock
      parent = mock
      select_node = mock
      parent.stubs(:node).returns(parent_node)
      parent_node.expects(:find).with('select_locator').returns(select_node)

      @select = Select.new(parent, :locator => 'select_locator')
    end

    def test_set
      @select.node.expects(:select).with('value')
      @select.set('value')
    end

    def test_selected_option
      unselected_mock = mock { expects(:selected?).returns(false) }
      selected_mock = mock { expects(:selected?).returns(true) }
      @select.expects(:options).returns([unselected_mock, selected_mock])

      assert_equal selected_mock, @select.selected_option
    end

    def test_options
      @select.node.expects(:find).with(:xpath, '.').returns('unused')
      options = @select.options

      assert options.class.ancestors.include?(Collection)
      assert_equal 'option', options.item_locator
    end

    def test_options__option_methods
      options_node = mock
      @select.node.expects(:find).with(:xpath, '.').returns(options_node)

      option_node = mock
      options_node.expects(:all).with(:xpath, './/option').returns('unused')
      options_node.expects(:find).with(:xpath, './/option[1]').returns(option_node)

      option = @select.options[0]

      option_node.expects(:select_option)
      option.select

      option_node.expects(:selected?).returns('answer_to_return')
      assert_equal 'answer_to_return', option.selected?
    end

  end
end

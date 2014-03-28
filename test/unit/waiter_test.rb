require 'unit_helper'

module AePageObjects
  class WaiterTest < Test::Unit::TestCase
    def test_wait_for
      Capybara.expects(:default_wait_time).returns(5)

      block_calls = sequence('calls')
      Capybara.expects(:using_wait_time).in_sequence(block_calls).with(0).yields.returns(false)
      Capybara.expects(:using_wait_time).in_sequence(block_calls).with(0).yields.returns(true)

      block = mock
      block.expects(:called).times(2)
      result = Waiter.wait_for do
        block.called
      end

      assert_equal true, result
    end

    def test_wait_for__timeout
      Capybara.stubs(:default_wait_time).returns(1)

      result = Waiter.wait_for do
        false
      end

      assert_equal false, result
    end
  end
end

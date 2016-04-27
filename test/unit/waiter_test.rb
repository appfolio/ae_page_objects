require 'unit_helper'

module AePageObjects
  class WaiterTest < AePageObjectsTestCase
    def test_wait_for
      Waiter.expects(:warn).with("[DEPRECATION WARNING]: AePageObjects::Waiter.wait_for is deprecated and will be removed in version 2.0.0. Use AePageObjects.poll_until instead.")

      Waiter.expects(:wait_until_return_false).yields.returns("stuff")

      block = mock(:called => true)
      result = Waiter.wait_for do
        block.called
      end
    end

    def test_wait_until
      Waiter.expects(:warn).with("[DEPRECATION WARNING]: AePageObjects::Waiter.wait_until is deprecated and will be removed in version 2.0.0. Use AePageObjects.poll_until instead.")

      Capybara.expects(:default_wait_time).returns(5)

      block_calls = sequence('calls')
      Capybara.expects(:using_wait_time).in_sequence(block_calls).with(0).yields.returns(false)
      Capybara.expects(:using_wait_time).in_sequence(block_calls).with(0).yields.returns(true)

      block = mock
      block.expects(:called).times(2)
      result = Waiter.wait_until do
        block.called
      end

      assert_equal true, result
    end

    def test_wait_until__timeout
      Waiter.expects(:warn).with("[DEPRECATION WARNING]: AePageObjects::Waiter.wait_until is deprecated and will be removed in version 2.0.0. Use AePageObjects.poll_until instead.")

      Capybara.stubs(:default_wait_time).returns(1)

      result = Waiter.wait_until do
        false
      end

      assert_equal false, result
    end

    def test_wait_until__frozen_time
      Waiter.expects(:warn).with("[DEPRECATION WARNING]: AePageObjects::Waiter.wait_until is deprecated and will be removed in version 2.0.0. Use AePageObjects.poll_until instead.")

      Capybara.stubs(:default_wait_time).returns(5)
      Time.stubs(:now).returns(1)

      block = mock
      block.expects(:called).times(1)

      raised = assert_raises FrozenInTime do
        Waiter.wait_until do
          block.called
        end
      end
     assert_equal "Time appears to be frozen", raised.message
    end

    def test_wait_until__set_wait_time
      Waiter.expects(:warn).with("[DEPRECATION WARNING]: AePageObjects::Waiter.wait_until is deprecated and will be removed in version 2.0.0. Use AePageObjects.poll_until instead.")

      Capybara.expects(:default_wait_time).never

      block_calls = sequence('calls')
      time_calls  = sequence('time')

      9.times { |n| Time.expects(:now).in_sequence(time_calls).returns(n) }
      4.times { Capybara.expects(:using_wait_time).in_sequence(block_calls).with(0).yields.returns(false) }
      Capybara.expects(:using_wait_time).in_sequence(block_calls).with(0).yields.returns(true)

      block = mock
      block.expects(:called).times(5)
      result = Waiter.wait_until(10) do
        block.called
      end

      assert_equal true, result
    end

    def test_wait_until__set_wait_time_time_out
      Waiter.expects(:warn).with("[DEPRECATION WARNING]: AePageObjects::Waiter.wait_until is deprecated and will be removed in version 2.0.0. Use AePageObjects.poll_until instead.")

      Capybara.expects(:default_wait_time).never

      block_calls = sequence('calls')
      time_calls  = sequence('time')

      12.times { |n| Time.expects(:now).in_sequence(time_calls).returns(n) }
      6.times { Capybara.expects(:using_wait_time).in_sequence(block_calls).with(0).yields.returns(false) }

      block = mock
      block.expects(:called).times(6)
      result = Waiter.wait_until(10) do
        block.called
      end

      assert_equal false, result
    end

    def test_wait_until_bang
      Waiter.expects(:warn).with("[DEPRECATION WARNING]: AePageObjects::Waiter.wait_until! is deprecated and will be removed in version 2.0.0. Use AePageObjects.poll_until instead.")

      Capybara.stubs(:default_wait_time).returns(1)

      my_obj = Object.new

      result = Waiter.wait_until! do
        my_obj
      end

      assert_equal my_obj, result
    end

    def test_wait_until_bang__exception
      Waiter.expects(:warn).with("[DEPRECATION WARNING]: AePageObjects::Waiter.wait_until! is deprecated and will be removed in version 2.0.0. Use AePageObjects.poll_until instead.")

      Capybara.stubs(:default_wait_time).returns(1)

      assert_raises WaitTimeoutError do
        Waiter.wait_until! do
          false
        end
      end
    end

    def test_wait_until_bang__set_timeout
      Waiter.expects(:warn).with("[DEPRECATION WARNING]: AePageObjects::Waiter.wait_until! is deprecated and will be removed in version 2.0.0. Use AePageObjects.poll_until instead.")

      my_obj = Object.new
      AePageObjects.expects(:poll_until).with(20).returns(my_obj)

      result = Waiter.wait_until!(20) {}

      assert_equal my_obj, result
    end
  end
end

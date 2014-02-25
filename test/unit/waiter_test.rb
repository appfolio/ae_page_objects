require 'unit_helper'

module AePageObjects
  class WaiterTest < Test::Unit::TestCase
    def test_wait_for
      Capybara.expects(:default_wait_time).returns(:default_wait_time)
      Timeout.expects(:timeout).with(:default_wait_time).yields

      block_calls = sequence('calls')
      Capybara.expects(:using_wait_time).in_sequence(block_calls).with(0).yields.returns(false)
      Capybara.expects(:using_wait_time).in_sequence(block_calls).with(0).yields.returns(true)

      block = mock
      block.expects(:called).times(2)
      Waiter.wait_for do
        block.called
      end
    end

    def test_wait_for__timeout
      Timeout.expects(:timeout).raises(Timeout::Error)

      assert !Waiter.wait_for
    end
  end
end
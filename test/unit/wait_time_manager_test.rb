require 'unit_helper'
require 'ae_page_objects/util/wait_time_manager'

module AePageObjects
  class WaitTimeManagerTest < AePageObjectsTestCase
    def test_using_wait_time__first_invocation__uses_min_wait_time
      manager = WaitTimeManager.new(0.1, 1.0)
      manager.using_wait_time do
        assert_equal 0.1, AePageObjects.send(:default_max_wait_time)
      end
    end

    def test_using_wait_time__first_invocation__does_not_exceed_max_time
      manager = WaitTimeManager.new(1.0, 0.1)
      manager.using_wait_time do
        assert_equal 0.1, AePageObjects.send(:default_max_wait_time)
      end
    end

    def test_using_wait_time__block_is_fast__wait_time_should_not_increase
      manager = WaitTimeManager.new(0.1, 1.0)
      manager.using_wait_time do
        true
      end

      manager.using_wait_time do
        assert_equal 0.1, AePageObjects.send(:default_max_wait_time)
      end
    end

    def test_using_wait_time__block_is_slow__wait_time_should_increase
      manager = WaitTimeManager.new(0.1, 1.0)
      manager.using_wait_time do
        sleep 0.2
      end

      manager.using_wait_time do
        assert_equal 0.2, AePageObjects.send(:default_max_wait_time)
      end
    end

    def test_using_wait_time__block_is_slow__wait_time_should_increase_but_not_exceed_max_time
      manager = WaitTimeManager.new(0.1, 0.15)
      manager.using_wait_time do
        sleep 0.2
      end

      manager.using_wait_time do
        assert_equal 0.15, AePageObjects.send(:default_max_wait_time)
      end
    end

    def test_using_wait_time__block_result__is_returned
      manager = WaitTimeManager.new(0.1, 1.0)
      result = manager.using_wait_time do
        'hello'
      end

      assert_equal 'hello', result
    end
  end
end

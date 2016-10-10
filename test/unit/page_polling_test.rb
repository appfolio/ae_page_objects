require 'unit_helper'
require 'ae_page_objects/util/page_polling'

class PagePollingTest < AePageObjectsTestCase
  class Dummy
    include AePageObjects::PagePolling
    def do_the_poll
      poll_until do
        yield
      end
    end
  end

  def setup
    super
    stub_capybara
  end

  def test_poll_until__should_use_zero_wait_time
    assert_not_equal 0, AePageObjects.default_max_wait_time

    result = do_the_poll do
      assert_equal 0, AePageObjects.default_max_wait_time
      :hello
    end
  end

  def test_poll_until__should_return_the_result
    result = do_the_poll do
      :hello
    end

    assert_equal :hello, result
  end

  def test_poll_until__should_retry_poll_until_errors
    invocation_count = 0
    result = do_the_poll do
      invocation_count += 1
      raise Capybara::ElementNotFound, 'oops' if invocation_count < 3
      :hello
    end

    assert_equal 3, invocation_count
  end

  def test_poll_until__should_raise_non_poll_until_errors
    invocation_count = 0
    assert_raises RuntimeError do
      do_the_poll do
        invocation_count += 1
        raise RuntimeError, 'oops' if invocation_count < 3
        :hello
      end
    end
    assert_equal 1, invocation_count
  end

  private

  def stub_capybara
    capybara = capybara_stub
    capybara.driver.stubs(:invalid_element_errors).returns([])
  end

  def do_the_poll(&block)
    Dummy.new.do_the_poll(&block)
  end
end

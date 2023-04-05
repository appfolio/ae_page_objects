require 'unit_helper'
require 'ae_page_objects/multiple_windows/browser'
require 'ae_page_objects/single_window/browser'

class AePageObjectsTest < AePageObjectsTestCase

  def test_browser__selenium
    Capybara.expects(:current_session).returns(mock(:driver => Capybara::Selenium::Driver.new(mock)))
    assert_equal AePageObjects::MultipleWindows::Browser, AePageObjects.browser.class
  end

  def test_browser__other
    Capybara.expects(:current_session).returns(mock(:driver => Object.new))
    assert_equal AePageObjects::SingleWindow::Browser, AePageObjects.browser.class
  end

  def test_wait_until__something_truthy__returns_result
    assert_equal "hello", AePageObjects.wait_until { "hello" }
  end

  def test_wait_until__waits_until_truthy__returns_result
    capybara_stub

    count = 0
    assert_equal 5, AePageObjects.wait_until(2) { count += 1; count == 5 ? count : nil }
  end

  def test_wait_until__timeout__raises_wait_timeout_error
    capybara_stub

    assert_raises AePageObjects::WaitTimeoutError do
      AePageObjects.wait_until(0.1) { false }
    end
  end

  def test_wait_until__frozen_time
    capybara_stub

    AePageObjects.stubs(:default_max_wait_time).returns(5)
    Time.stubs(:now).returns(1)

    block = mock("block")
    block.expects(:called).times(1)

    raised = assert_raises AePageObjects::FrozenInTime do
      AePageObjects.wait_until do
        block.called
      end
    end
    assert_equal "Time appears to be frozen", raised.message
  end

  def test_wait_until__recursive_invocation__should_let_top_level_be_in_control
    capybara_stub
    count = 0

    AePageObjects.wait_until do
      begin
        AePageObjects.wait_until do
          count += 1
          false
        end
      rescue AePageObjects::WaitTimeoutError
      end

      true
    end

    assert_equal 1, count
  end

  def test_wait_until__recoverable_error_raised__should_rescue_and_retry
    capybara_stub
    count = 0

    AePageObjects.wait_until do
      count += 1
      if count == 3
        true
      else
        raise Capybara::ElementNotFound
      end
    end

    assert_equal 3, count
  end

  def test_wait_until__non_recoverable_error_raised__should_re_raise
    capybara_stub
    count = 0

    assert_raises RuntimeError do
      AePageObjects.wait_until do
        count += 1
        if count == 3
          true
        else
          raise RuntimeError
        end
      end
    end

    assert_equal 1, count
  end

  def test_default_router
    assert_kind_of AePageObjects::BasicRouter, AePageObjects.default_router
  end
end

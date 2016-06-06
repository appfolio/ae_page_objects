require 'unit_helper'

class AePageObjectsTest < AePageObjectsTestCase

  def test_browser__selenium
    Capybara.expects(:current_session).returns(mock(:driver => Capybara::Selenium::Driver.new(mock)))
    assert_equal AePageObjects::MultipleWindows::Browser, AePageObjects.browser.class
  end

  def test_browser__other
    Capybara.expects(:current_session).returns(mock(:driver => Object.new))
    assert_equal AePageObjects::SingleWindow::Browser, AePageObjects.browser.class
  end

  def test_wait_until__returns_result_when_true
    assert_equal "hello", AePageObjects.wait_until { "hello" }
  end

  def test_wait_until__tries_within_timeout
    count = 0
    assert_equal 5, AePageObjects.wait_until(2) { count += 1; count == 5 ? count : nil }
  end

  def test_wait_until__timeout
    assert_raises AePageObjects::WaitTimeoutError do
      AePageObjects.wait_until(0.1) { false }
    end
  end

  def test_wait_until__frozen_time
    AePageObjects.stubs(:default_max_wait_time).returns(5)
    Time.stubs(:now).returns(1)

    block = mock
    block.expects(:called).times(1)

    raised = assert_raises AePageObjects::FrozenInTime do
      AePageObjects.wait_until do
        block.called
      end
    end
    assert_equal "Time appears to be frozen", raised.message
  end

  def test_default_router
    assert_kind_of AePageObjects::BasicRouter, AePageObjects.default_router
  end
end

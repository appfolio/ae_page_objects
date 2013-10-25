require 'unit_helper'

module AePageObjects
  class WindowHandleManagerTest < Test::Unit::TestCase

    def test_browser
      capybara_stub.driver.expects(:browser).returns(:browser)
      assert_equal :browser, Window::HandleManager.browser
    end

    def test_all
      capybara_stub.browser.expects(:window_handles).returns(:window_handles)
      assert_equal :window_handles, Window::HandleManager.all
    end

    def test_current
      Window::HandleManager.expects(:all).returns([:handle])
      capybara_stub.browser.expects(:window_handle).returns(:window_handle)

      assert_equal :window_handle, Window::HandleManager.current
    end

    def test_current__empty
      Window::HandleManager.expects(:all).returns([])
      capybara_stub.browser.expects(:window_handle).never

      assert_equal nil, Window::HandleManager.current
    end

    def test_close__last_window
      Window::HandleManager.expects(:all).returns([:handle1])
      Window::HandleManager.expects(:current).never

      capybara_stub.browser.expects(:switch_to).never
      capybara_stub.browser.expects(:close).never

      assert_equal false, Window::HandleManager.close(:handle2)
    end

    def test_close__no_windows
      Window::HandleManager.expects(:all).returns([])
      Window::HandleManager.expects(:current).never

      capybara_stub.browser.expects(:switch_to).never
      capybara_stub.browser.expects(:close).never

      assert_equal false, Window::HandleManager.close(:handle2)
    end

    def test_close__not_current
      Window::HandleManager.expects(:all).returns([:handle1, :handle2, :handle3])
      Window::HandleManager.expects(:current).returns(:handle3)

      switch_to_sequence = sequence('switch_to')
      switch_to_stub = mock
      switch_to_stub.expects(:window).with(:handle2).in_sequence(switch_to_sequence)
      switch_to_stub.expects(:window).with(:handle3).in_sequence(switch_to_sequence)

      capybara_stub.browser.stubs(:switch_to).returns(switch_to_stub)
      capybara_stub.browser.expects(:close)

      assert_equal true, Window::HandleManager.close(:handle2)
    end

    def test_close__current
      all_sequence = sequence('all')

      Window::HandleManager.expects(:all).returns([:handle1, :handle2, :handle3]).in_sequence(all_sequence)
      Window::HandleManager.expects(:all).returns([:handle1, :handle3]).in_sequence(all_sequence)

      Window::HandleManager.expects(:current).returns(:handle2)

      switch_to_sequence = sequence('switch_to')
      switch_to_stub = mock
      switch_to_stub.expects(:window).with(:handle2).in_sequence(switch_to_sequence)
      switch_to_stub.expects(:window).with(:handle1).in_sequence(switch_to_sequence)

      capybara_stub.browser.stubs(:switch_to).returns(switch_to_stub)
      capybara_stub.browser.expects(:close)

      assert_equal true, Window::HandleManager.close(:handle2)
    end
  end
end

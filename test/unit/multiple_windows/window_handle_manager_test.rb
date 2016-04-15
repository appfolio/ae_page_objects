require 'unit_helper'

module AePageObjects
  module MultipleWindows
    class WindowHandleManagerTest < AePageObjectsTestCase

      def test_browser
        capybara_stub.driver.expects(:browser).returns(:browser)
        assert_equal :browser, WindowHandleManager.browser
      end

      def test_all
        capybara_stub.browser.expects(:window_handles).returns(:window_handles)
        assert_equal :window_handles, WindowHandleManager.all
      end

      def test_current
        WindowHandleManager.expects(:all).returns([:handle])
        capybara_stub.browser.expects(:window_handle).returns(:window_handle)

        assert_equal :window_handle, WindowHandleManager.current
      end

      def test_current__empty
        WindowHandleManager.expects(:all).returns([])
        capybara_stub.browser.expects(:window_handle).never

        assert_equal nil, WindowHandleManager.current
      end

      def test_current__not_found
        WindowHandleManager.expects(:all).returns([:handle])

        capybara_stub.browser.expects(:window_handle).raises(Selenium::WebDriver::Error::NoSuchWindowError)
        capybara_stub.driver.expects(:is_a?).with(Capybara::Selenium::Driver).returns(true)

        assert_raises WindowNotFound do
          WindowHandleManager.current
        end
      end

      def test_close__last_window
        WindowHandleManager.expects(:all).returns([:handle1])
        WindowHandleManager.expects(:current).never

        capybara_stub.browser.expects(:switch_to).never
        capybara_stub.browser.expects(:close).never

        assert_equal false, WindowHandleManager.close(:handle2)
      end

      def test_close__no_windows
        WindowHandleManager.expects(:all).returns([])
        WindowHandleManager.expects(:current).never

        capybara_stub.browser.expects(:switch_to).never
        capybara_stub.browser.expects(:close).never

        assert_equal false, WindowHandleManager.close(:handle2)
      end

      def test_close__not_current
        WindowHandleManager.expects(:all).returns([:handle1, :handle2, :handle3])
        WindowHandleManager.expects(:current).returns(:handle3)

        switch_to_sequence = sequence('switch_to')
        switch_to_stub = mock
        switch_to_stub.expects(:window).with(:handle2).in_sequence(switch_to_sequence)
        switch_to_stub.expects(:window).with(:handle3).in_sequence(switch_to_sequence)

        capybara_stub.browser.stubs(:switch_to).returns(switch_to_stub)
        capybara_stub.browser.expects(:close)

        assert_equal true, WindowHandleManager.close(:handle2)
      end

      def test_close__current
        all_sequence = sequence('all')

        WindowHandleManager.expects(:all).returns([:handle1, :handle2, :handle3]).in_sequence(all_sequence)
        WindowHandleManager.expects(:all).returns([:handle1, :handle3]).in_sequence(all_sequence)

        WindowHandleManager.expects(:current).returns(:handle2)

        switch_to_sequence = sequence('switch_to')
        switch_to_stub = mock
        switch_to_stub.expects(:window).with(:handle2).in_sequence(switch_to_sequence)
        switch_to_stub.expects(:window).with(:handle1).in_sequence(switch_to_sequence)

        capybara_stub.browser.stubs(:switch_to).returns(switch_to_stub)
        capybara_stub.browser.expects(:close)

        assert_equal true, WindowHandleManager.close(:handle2)
      end
    end
  end
end

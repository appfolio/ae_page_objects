require 'unit_helper'

module AePageObjects
  module MultipleWindows
    class WindowTest < AePageObjectsTestCase

      def test_initialize
        registered_window = nil

        registry = mock
        registry.expects(:add).with do |w|
          registered_window = w
          true
        end

        window = Window.new(registry, "window_handle")

        assert_equal registered_window, window
        assert_equal "window_handle", window.handle
        assert_nil window.current_document
      end

      def test_current_document=
        registry = mock(:add => nil)

        window = Window.new(registry, "window_handle")

        assert_nil window.current_document

        document_mock = mock(:stale! => true)
        window.current_document = document_mock

        assert_equal document_mock, window.current_document

        window.current_document = "whatever"
        assert_equal "whatever", window.current_document
      end

      def test_switch_to
        registry = mock(:add => nil)

        window = Window.new(registry, "window_handle")

        window.current_document = "current_document"

        navigator_mock = stub
        navigator_mock.expects(:window).with("window_handle")
        capybara_stub.browser.expects(:switch_to).returns(navigator_mock)

        assert_equal "current_document", window.switch_to
      end

      def test_close__window_closed
        registry = mock(:add => nil)

        window = Window.new(registry, "window_handle")

        document_mock = mock(:stale! => true)
        window.current_document = document_mock

        WindowHandleManager.expects(:close).with("window_handle").returns(true)

        unregistered_window = nil
        registry.expects(:remove).with do |w|
          unregistered_window = w
          true
        end
        window.close

        assert_equal unregistered_window, window
      end

      def test_close__window_not_closed
        registry = mock(:add => nil)

        window = Window.new(registry, "window_handle")

        window.expects(:current_document=).never
        WindowHandleManager.expects(:close).with("window_handle").returns(false)

        registry.expects(:remove).never
        window.close
      end
    end
  end
end

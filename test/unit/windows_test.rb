require 'unit_helper'

module AePageObjects
  class WindowsTest < Test::Unit::TestCase

    def test_opened_windows
      windows = Windows.new

      Window::HandleManager.expects(:all).returns(["handle1", "handle2", "handle3"])
      assert_equal ["handle1", "handle2", "handle3"], windows.opened_windows.map(&:handle).sort
    end

    def test_close_all
      windows = Windows.new
      windows.expects(:opened_windows).returns([mock(:close => true), mock(:close => true), mock(:close => true)])

      assert_nothing_raised do
        windows.close_all
      end
    end

    def test_current_window__none
      windows = Windows.new

      Window::HandleManager.expects(:current).returns("window_handle")
      window = windows.current_window

      assert_equal window, windows.instance_variable_get(:@windows)[window.handle]
      assert_equal "window_handle", window.handle

      Window::HandleManager.expects(:current).returns("window_handle")
      assert_equal window, windows.current_window
    end

    def test_current_window__many
      windows = Windows.new

      window1 = windows.send(:create_window, "window_handle1")
      window2 = windows.send(:create_window, "window_handle2")
      window3 = windows.send(:create_window, "window_handle3")

      Window::HandleManager.expects(:current).returns("window_handle1")
      assert_equal window1, windows.current_window

      Window::HandleManager.expects(:current).returns("window_handle2")
      assert_equal window2, windows.current_window

      Window::HandleManager.expects(:current).returns("window_handle3")
      assert_equal window3, windows.current_window
    end

    def test_find_document
      finder_mock = mock
      finder_mock.expects(:find).with(:url => 'hello_kitty').yields.returns(:found)

      windows = Windows.new

      AePageObjects::DocumentFinder.expects(:new).with(windows, AePageObjects::Document).returns(finder_mock)

      block_called = false
      result = windows.find_document(AePageObjects::Document, :url => 'hello_kitty') do
        block_called = true
      end

      assert_equal :found, result
      assert block_called
    end
  end
end

require 'unit_helper'

module AePageObjects
  class WindowListTest < Test::Unit::TestCase

    def test_opened_windows
      windows = WindowList.new

      Window::HandleManager.expects(:all).returns(["handle1", "handle2", "handle3"])
      assert_equal ["handle1", "handle2", "handle3"], windows.opened.map(&:handle).sort
    end

    def test_close_all
      windows = WindowList.new
      windows.expects(:opened).returns([mock(:close => true), mock(:close => true), mock(:close => true)])

      assert_nothing_raised do
        windows.close_all
      end
    end

    def test_current_window__none
      windows = WindowList.new

      Window::HandleManager.expects(:current).returns("window_handle")
      window = windows.current_window

      assert_equal window, windows.instance_variable_get(:@windows)[window.handle]
      assert_equal "window_handle", window.handle

      Window::HandleManager.expects(:current).returns("window_handle")
      assert_equal window, windows.current_window
    end

    def test_current_window__many
      windows = WindowList.new

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
  end
end

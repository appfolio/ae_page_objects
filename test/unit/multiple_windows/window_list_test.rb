require 'unit_helper'

module AePageObjects
  module MultipleWindows
    class WindowListTest < Test::Unit::TestCase

      def test_opened_windows
        windows = WindowList.new

        WindowHandleManager.expects(:all).returns(["handle1", "handle2", "handle3"])
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

        WindowHandleManager.expects(:current).returns("window_handle")
        window = windows.current_window

        assert_equal window, windows.instance_variable_get(:@windows)[window.handle]
        assert_equal "window_handle", window.handle

        WindowHandleManager.expects(:current).returns("window_handle")
        assert_equal window, windows.current_window
      end

      def test_current_window__many
        windows = WindowList.new

        window1 = windows.send(:window_for, "window_handle1")
        window2 = windows.send(:window_for, "window_handle2")
        window3 = windows.send(:window_for, "window_handle3")

        WindowHandleManager.expects(:current).returns("window_handle1")
        assert_equal window1, windows.current_window

        WindowHandleManager.expects(:current).returns("window_handle2")
        assert_equal window2, windows.current_window

        WindowHandleManager.expects(:current).returns("window_handle3")
        assert_equal window3, windows.current_window
      end

      def current_window
        current_handle = WindowHandleManager.current

        window_for(current_handle) if current_handle
      rescue WindowNotFound
        synchronize_windows

        if current_window = @windows.values.first
          current_window.switch_to
          current_window
        end
      end

      def test_current_window__not_found__causes_synchronize
        window1 = stub(:handle => "1")
        window2 = stub(:handle => "2")
        window3 = stub(:handle => "3")

        windows = WindowList.new
        windows.add(window1)
        windows.add(window2)
        windows.add(window3)

        WindowHandleManager.expects(:current).raises(WindowNotFound)
        WindowHandleManager.expects(:all).returns(["3", "1"])
        window1.expects(:switch_to)
        current = windows.current_window

        assert_equal window1, current
      end
    end
  end
end
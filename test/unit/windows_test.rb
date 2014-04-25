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
      document_class = Class.new(AePageObjects::Document)
      windows = Windows.new
      windows.expects(:current_window).returns(:current_window)

      the_block = proc do
      end

      proxy = windows.find_document(document_class, :ignore_current => true, &the_block)

      assert_equal true, proxy.is_a?(DocumentProxy)

      page_loader = proxy.instance_variable_get(:@page_loader)
      assert_equal PageLoader, page_loader.class

      query = page_loader.instance_variable_get(:@query)
      assert_equal DocumentQuery, query.class

      query_conditions = query.conditions
      assert_equal 1, query_conditions.size

      condition = query_conditions.first
      assert_equal document_class, condition.document_class
      assert_equal true, condition.page_conditions[:ignore_current]
      assert_equal the_block, condition.page_conditions[:block]

      strategy = page_loader.instance_variable_get(:@strategy)
      assert_equal PageLoader::CrossWindow, strategy.class

      window_list = strategy.instance_variable_get(:@window_list)
      assert_equal windows, window_list
    end
  end
end

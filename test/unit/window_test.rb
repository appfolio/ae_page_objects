require 'unit_helper'

module AePageObjects
  class WindowTest < AePageObjectsTestCase

    def test_all
      Window.expects(:warn)

      browser = MultipleWindows::Browser.new
      AePageObjects.expects(:browser).returns(browser)

      windows = Window.all
      assert_equal MultipleWindows::WindowList, windows.class
    end

    def test_close_all
      browser = MultipleWindows::Browser.new
      browser.windows.expects(:close_all)
      AePageObjects.expects(:browser).returns(browser)

      Window.expects(:warn).times(2)
      assert_nothing_raised do
        Window.close_all
      end
    end
  end
end

require 'unit_helper'

module AePageObjects
  class WindowTest < ActiveSupport::TestCase

    def test_initialize
      window = Window.new("window_handle")
      assert_equal "window_handle", window.handle
      assert_nil window.current_document
      assert_equal window, Window.all[window]
    end

    def test_current_document=
      window = Window.new("window_handle")
      assert_nil window.current_document

      document_mock = mock(:stale! => true)
      window.current_document = document_mock

      assert_equal document_mock, window.current_document

      window.current_document = "whatever"
      assert_equal "whatever", window.current_document
    end

    def test_switch_to
      window = Window.new("window_handle")
      window.current_document = "current_document"

      capybara_stub.browser.expects(:switch_to).with("window_handle")

      assert_equal "current_document", window.switch_to
    end

    def test_close
      window = Window.new("window_handle")
      assert_equal window, Window.all[window]

      document_mock = mock(:stale! => true)
      window.current_document = document_mock

      capybara_stub.driver.expects(:close)

      window.close

      assert_nil Window.all[window]
    end

    def test_current__none
      capybara_stub.browser.expects(:window_handle).returns("window_handle")

      window = Window.current
      assert_equal window, Window.all[window]

      capybara_stub.browser.expects(:window_handle).returns("window_handle")
      assert_equal window, Window.current
    end

    def test_current__many
      window1 = Window.new("window_handle1")
      window2 = Window.new("window_handle2")
      window3 = Window.new("window_handle3")

      capybara_stub.browser.expects(:window_handle).returns("window_handle1")
      assert_equal window1, Window.current

      capybara_stub.browser.expects(:window_handle).returns("window_handle2")
      assert_equal window2, Window.current

      capybara_stub.browser.expects(:window_handle).returns("window_handle3")
      assert_equal window3, Window.current
    end
  end
end

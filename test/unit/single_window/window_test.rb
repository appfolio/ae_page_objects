require 'unit_helper'

require 'ae_page_objects/single_window/window'

module AePageObjects
  module SingleWindow
    class WindowTest < AePageObjectsTestCase

      def test_initialize
        window = Window.new

        assert_nil window.current_document
      end

      def test_current_document=
        window = Window.new

        assert_nil window.current_document

        document_mock = mock(:stale! => true)
        window.current_document = document_mock

        assert_equal document_mock, window.current_document

        window.current_document = "whatever"
        assert_equal "whatever", window.current_document
      end
    end
  end
end

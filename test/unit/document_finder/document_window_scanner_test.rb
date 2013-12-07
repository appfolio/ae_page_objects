require 'unit_helper'

module AePageObjects
  class DocumentFinder
    class DocumentWindowScannerTest < Test::Unit::TestCase

      def test_find__found
        all_windows = [
          mock,
          mock,
          mock,
        ]

        scanner = AePageObjects::DocumentFinder::DocumentWindowScanner.new(mock, :start_window, all_windows, mock)

        load_from_window_sequence = sequence('load_from_window')
        scanner.expects(:load_from_window).in_sequence(load_from_window_sequence).with(:start_window, true).returns(nil)
        scanner.expects(:load_from_window).in_sequence(load_from_window_sequence).with(all_windows.first, false).returns(:found_it)

        window = scanner.find
        assert_equal :found_it, window
      end

      def test_find__not_found
        all_windows = [
          mock,
          mock,
          mock,
        ]

        scanner = AePageObjects::DocumentFinder::DocumentWindowScanner.new(mock, :start_window, all_windows, mock)

        load_from_window_sequence = sequence('load_from_window')
        scanner.expects(:load_from_window).in_sequence(load_from_window_sequence).with(:start_window, true).returns(nil)
        scanner.expects(:load_from_window).in_sequence(load_from_window_sequence).with(all_windows[0], false).returns(nil)
        scanner.expects(:load_from_window).in_sequence(load_from_window_sequence).with(all_windows[1], false).returns(nil)
        scanner.expects(:load_from_window).in_sequence(load_from_window_sequence).with(all_windows[2], false).returns(nil)

        window = scanner.find
        assert_equal nil, window
      end

      def test_load_from_window__success
        document_class = mock(:new => :instance)
        conditions = mock
        conditions.expects(:match?).with(:instance, true).returns(true)

        scanner = AePageObjects::DocumentFinder::DocumentWindowScanner.new(document_class, :start_window, [], conditions)
        result = scanner.send(:load_from_window, mock(:switch_to => true), is_current = true)
        assert_equal :instance, result
      end

      def test_load_from_window__failure
        document_class = mock(:new => :instance)
        conditions = mock
        conditions.expects(:match?).with(:instance, true).returns(false)

        scanner = AePageObjects::DocumentFinder::DocumentWindowScanner.new(document_class, :start_window, [], conditions)
        result = scanner.send(:load_from_window, mock(:switch_to => true), is_current = true)
        assert_equal nil, result
      end

      def test_load_from_window__loading_failed
        document_class = mock
        document_class.expects(:new).raises(AePageObjects::LoadingFailed.new)

        scanner = AePageObjects::DocumentFinder::DocumentWindowScanner.new(document_class, :start_window, [], mock)
        result = scanner.send(:load_from_window, mock(:switch_to => true), is_current = true)
        assert_equal nil, result
      end
    end
  end
end
require 'unit_helper'

require 'ae_page_objects/multiple_windows/cross_window_loader_strategy'
require 'ae_page_objects/multiple_windows/window_list'

require 'ae_page_objects/document_query'

module AePageObjects
  module MultipleWindows
    class CrossWindowLoaderStrategyTest < AePageObjectsTestCase
      class DocumentClass
      end

      def test_load_page_with_condition__found__current_window
        current_window = mock("current_window")

        window_list = WindowList.new
        window_list.expects(:current_window).returns(current_window)

        loader = CrossWindowLoaderStrategy.new(window_list)
        current_window_loader = loader.instance_variable_get(:@current_window_loader)

        condition = DocumentQuery::Condition.new(DocumentClass)

        current_window.expects(:switch_to)

        current_window_loader.expects(:load_document_with_condition).with(condition).returns(:page)

        window = loader.load_document_with_condition(condition)
        assert_equal :page, window
      end

      def test_load_page_with_condition__found__other_window
        current_window = mock("current_window")
        other_window   = mock

        window_list = WindowList.new
        window_list.expects(:current_window).returns(current_window)
        window_list.expects(:opened).returns([
          current_window,
          other_window,
        ])

        loader = CrossWindowLoaderStrategy.new(window_list)
        current_window_loader = loader.instance_variable_get(:@current_window_loader)

        condition = DocumentQuery::Condition.new(DocumentClass)

        current_window_loader_sequence = sequence('current_window_loader_sequence')

        current_window.expects(:switch_to)
        current_window_loader.expects(:load_document_with_condition).in_sequence(current_window_loader_sequence).with(condition).returns(nil)

        other_window.expects(:switch_to)
        current_window_loader.expects(:load_document_with_condition).in_sequence(current_window_loader_sequence).with(condition).returns(:page)

        window = loader.load_document_with_condition(condition)
        assert_equal :page, window
      end

      def test_load_page_with_condition__found__other_window__ignore_current
        current_window = mock("current_window")
        other_window   = mock

        window_list = WindowList.new
        window_list.expects(:current_window).returns(current_window)
        window_list.expects(:opened).returns([
          current_window,
          other_window,
        ])

        loader = CrossWindowLoaderStrategy.new(window_list)
        current_window_loader = loader.instance_variable_get(:@current_window_loader)

        condition = DocumentQuery::Condition.new(DocumentClass, :ignore_current => true)

        current_window_loader_sequence = sequence('current_window_loader_sequence')

        other_window.expects(:switch_to)
        current_window_loader.expects(:load_document_with_condition).in_sequence(current_window_loader_sequence).with(condition).returns(:page)

        window = loader.load_document_with_condition(condition)
        assert_equal :page, window
      end

      def test_load_page_with_condition__not_found
        current_window = mock("current_window")
        other_window   = mock

        window_list = WindowList.new
        window_list.expects(:current_window).returns(current_window)
        window_list.expects(:opened).returns([
                                                       current_window,
                                                       other_window,
                                                     ])

        loader = CrossWindowLoaderStrategy.new(window_list)
        current_window_loader = loader.instance_variable_get(:@current_window_loader)

        condition = DocumentQuery::Condition.new(DocumentClass)

        current_window_loader_sequence = sequence('current_window_loader_sequence')

        current_window.expects(:switch_to).in_sequence(current_window_loader_sequence)
        current_window_loader.expects(:load_document_with_condition).in_sequence(current_window_loader_sequence).with(condition).returns(nil)

        other_window.expects(:switch_to).in_sequence(current_window_loader_sequence)
        current_window_loader.expects(:load_document_with_condition).in_sequence(current_window_loader_sequence).with(condition).returns(nil)

        current_window.expects(:switch_to).in_sequence(current_window_loader_sequence)

        window = loader.load_document_with_condition(condition)
        assert_equal nil, window
      end

      def test_document_not_loaded_error
        window_list = stub("window_list", 
          :current_window => true,
          :opened => [
            stub(:handle => "window1", :current_document => "Document1"),
            stub(:handle => "window2", :current_document => nil),
            stub(:handle => "window3", :current_document => "Document3"),
          ]
        )

        loader = CrossWindowLoaderStrategy.new(window_list)
        query = mock("query", :permitted_types_dump => "permitted_types_dump")

        error_message = loader.document_not_loaded_error_message(query)

        all_windows_dump = [
          {:window_handle => "window1", :document => "Document1"},
          {:window_handle => "window2", :document => "<none>"},
          {:window_handle => "window3", :document => "Document3"},
        ]

        assert_equal "Couldn't find document with type in permitted_types_dump in any of the open windows: #{all_windows_dump.inspect}", error_message
      end
    end
  end
end

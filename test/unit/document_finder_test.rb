require 'unit_helper'

module AePageObjects
  class DocumentFinderTest < Test::Unit::TestCase

    def test_find__conditions_passed_down
      current_window = mock
      AePageObjects::Window.expects(:current).returns(current_window)

      document_class = mock

      conditions = nil

      AePageObjects::Window.expects(:all).returns([])
      DocumentFinder::DocumentWindowScanner.expects(:new).with do |document_class_arg, current_window_arg, windows_arg, conditions_arg|
        conditions = conditions_arg

        document_class == document_class_arg && current_window == current_window_arg && [] == windows_arg
      end.returns(mock(:find => nil))

      some_block = proc { |page| }
      Waiter.expects(:wait_for).yields.returns(true)

      finder = AePageObjects::DocumentFinder.new(document_class)
      finder.find :url => 'hello_kitty', &some_block

      assert_equal({:url => 'hello_kitty', :block => some_block}, conditions.instance_variable_get(:@conditions))
    end

    def test_find__returns_wait_for_result
      current_window = mock
      AePageObjects::Window.expects(:current).returns(current_window)

      finder = AePageObjects::DocumentFinder.new(mock)

      Waiter.expects(:wait_for).yields.returns(:result)
      AePageObjects::Window.expects(:all).returns([])
      DocumentFinder::DocumentWindowScanner.expects(:new).returns(mock(:find => true))

      document = finder.find
      assert_equal :result, document
    end

    def test_find__timeout
      current_window = mock
      current_window.expects(:switch_to)
      AePageObjects::Window.expects(:current).returns(current_window)

      document_stub = Struct.new(:name)

      AePageObjects::Window.expects(:all).returns([
                                                    stub(:handle => "window1", :current_document => document_stub.new("document1")),
                                                    stub(:handle => "window2", :current_document => nil),
                                                    stub(:handle => "window3", :current_document => document_stub.new("document3")),
                                                  ])

      Waiter.expects(:wait_for).returns(nil)

      raised = assert_raises AePageObjects::PageNotFound do
        AePageObjects::DocumentFinder.new(mock(:name => "hello")).find
      end

      assert_include raised.message, "hello"
      assert_include raised.message, "window1"
      assert_include raised.message, "document1"
      assert_include raised.message, "window2"
      assert_include raised.message, "<none>"
      assert_include raised.message, "window3"
      assert_include raised.message, "document3"
    end
  end
end

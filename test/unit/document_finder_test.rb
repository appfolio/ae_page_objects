require 'unit_helper'

module AePageObjects
  class DocumentFinderTest < Test::Unit::TestCase

    def test_document_find__conditions_passed_down
      AePageObjects::Window.expects(:current).returns(mock)
      Capybara.expects(:wait_until).yields

      finder = AePageObjects::DocumentFinder.new(mock)

      conditions = nil
      finder.expects(:find_window).with do |find_window_arg|
        conditions = find_window_arg
        true
      end

      some_block = proc { |page| }
      finder.find :url => 'hello_kitty', &some_block

      assert_equal({:url => 'hello_kitty', :block => some_block}, conditions.instance_variable_get(:@conditions))
    end

    def test_document_find__returns_wait_until_result
      AePageObjects::Window.expects(:current).returns(mock)
      Capybara.expects(:wait_until).yields.returns(:result)

      finder = AePageObjects::DocumentFinder.new(mock)
      finder.expects(:find_window)

      document = finder.find
      assert_equal :result, document
    end

    def test_document_find__timeout
      current_window = mock
      current_window.expects(:switch_to)
      AePageObjects::Window.expects(:current).returns(current_window)

      document_stub = Struct.new(:name)

      AePageObjects::Window.expects(:all).returns([
                                                    stub(:handle => "window1", :current_document => document_stub.new("document1")),
                                                    stub(:handle => "window2", :current_document => nil),
                                                    stub(:handle => "window3", :current_document => document_stub.new("document3")),
                                                  ])

      Capybara.expects(:wait_until).raises(Capybara::TimeoutError)

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

    def test_find_window__found
      all_windows = [
        mock(:switch_to => true),
        mock(:switch_to => true),
        mock,
      ]

      AePageObjects::Window.expects(:all).returns(all_windows)

      finder = AePageObjects::DocumentFinder.new(mock)

      attempt_to_load_sequence = sequence('attempt_to_load')
      finder.expects(:attempt_to_load).in_sequence(attempt_to_load_sequence).returns(false)
      finder.expects(:attempt_to_load).in_sequence(attempt_to_load_sequence).returns(:found_it)

      window = finder.send(:find_window, mock)
      assert_equal :found_it, window
    end

    def test_find_window__not_found
      all_windows = [
        mock(:switch_to => true),
        mock(:switch_to => true),
        mock(:switch_to => true),
      ]

      AePageObjects::Window.expects(:all).returns(all_windows)

      finder = AePageObjects::DocumentFinder.new(mock)

      attempt_to_load_sequence = sequence('attempt_to_load')
      finder.expects(:attempt_to_load).in_sequence(attempt_to_load_sequence).returns(false)
      finder.expects(:attempt_to_load).in_sequence(attempt_to_load_sequence).returns(false)
      finder.expects(:attempt_to_load).in_sequence(attempt_to_load_sequence).returns(false)

      window = finder.send(:find_window, mock)
      assert_equal nil, window
    end

    def test_attempt_to_load__success
      conditions = mock
      conditions.expects(:match?).with(:instance).returns(true)

      result = AePageObjects::DocumentFinder.new(mock(:new => :instance)).send(:attempt_to_load, conditions)
      assert_equal :instance, result
    end

    def test_attempt_to_load__failure
      conditions = mock
      conditions.expects(:match?).with(:instance).returns(false)

      result = AePageObjects::DocumentFinder.new(mock(:new => :instance)).send(:attempt_to_load, conditions)
      assert_equal nil, result
    end

    def test_attempt_to_load__loading_failed
      document_class_mock = mock
      document_class_mock.expects(:new).raises(AePageObjects::LoadingFailed.new)

      result = AePageObjects::DocumentFinder.new(document_class_mock).send(:attempt_to_load, mock())
      assert_equal nil, result
    end
  end
end

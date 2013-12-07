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
      Capybara.expects(:wait_until).yields

      finder = AePageObjects::DocumentFinder.new(document_class)
      finder.find :url => 'hello_kitty', &some_block

      assert_equal({:url => 'hello_kitty', :block => some_block}, conditions.instance_variable_get(:@conditions))
    end

    def test_find__returns_wait_until_result
      current_window = mock
      AePageObjects::Window.expects(:current).returns(current_window)

      finder = AePageObjects::DocumentFinder.new(mock)

      Capybara.expects(:wait_until).yields.returns(:result)
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

    def test_document_window_scanner_find__found
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

    def test_document_window_scanner_find__not_found
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

    def test_document_window_scanner_load_from_window__success
      document_class = mock(:new => :instance)
      conditions = mock
      conditions.expects(:match?).with(:instance, true).returns(true)

      scanner = AePageObjects::DocumentFinder::DocumentWindowScanner.new(document_class, :start_window, [], conditions)
      result = scanner.send(:load_from_window, mock(:switch_to => true), is_current = true)
      assert_equal :instance, result
    end

    def test_document_window_scanner_load_from_window__failure
      document_class = mock(:new => :instance)
      conditions = mock
      conditions.expects(:match?).with(:instance, true).returns(false)

      scanner = AePageObjects::DocumentFinder::DocumentWindowScanner.new(document_class, :start_window, [], conditions)
      result = scanner.send(:load_from_window, mock(:switch_to => true), is_current = true)
      assert_equal nil, result
    end

    def test_document_window_scanner_load_from_window__loading_failed
      document_class = mock
      document_class.expects(:new).raises(AePageObjects::LoadingFailed.new)

      scanner = AePageObjects::DocumentFinder::DocumentWindowScanner.new(document_class, :start_window, [], mock)
      result = scanner.send(:load_from_window, mock(:switch_to => true), is_current = true)
      assert_equal nil, result
    end

    def test_conditions
      block_condition = proc do |page|
        page.is_starbucks?
      end
      conditions = DocumentFinder::Conditions.new({:ignore_current => true, :url => 'www.starbucks.com', :title => 'Coffee'}, block_condition)

      page = setup_page_for_conditions
      assert_equal true, conditions.match?(page, is_current = false)

      page = setup_page_for_conditions(:ignore_current => true)
      assert_equal false, conditions.match?(page, is_current = true)

      page = setup_page_for_conditions(:current_url => "www.whatever.com/bleh")
      assert_equal false, conditions.match?(page, is_current = false)

      page = setup_page_for_conditions(:title => "Best Darn Stuff")
      assert_equal false, conditions.match?(page, is_current = false)
    end

  private

    def setup_page_for_conditions(options = {})
      options = {
        :current_url    => "www.starbucks.com/bleh",
        :is_starbucks?  => true,
        :title          => "Best Darn Coffee",
        :ignore_current => true
      }.merge(options)

      capybara_stub.browser.stubs(:title).returns(options[:title])
      stub(:current_url => options[:current_url], :is_starbucks? => options[:is_starbucks?])
    end
  end
end

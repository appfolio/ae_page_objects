require 'unit_helper'

module AePageObjects
  class DocumentTest < Test::Unit::TestCase

    def test_document_find__extra_condition_passed_down
      AePageObjects::Window.expects(:current).returns(mock)
      Capybara.expects(:wait_until).yields
      AePageObjects::Document.expects(:find_window).yields

      block_called = false
      window = AePageObjects::Document.find do
        block_called = true
      end
      assert block_called
    end

    def test_document_find__returns_wait_until_result
      AePageObjects::Window.expects(:current).returns(mock)
      Capybara.expects(:wait_until).yields.returns(:result)
      AePageObjects::Document.expects(:find_window)

      window = AePageObjects::Document.find
      assert_equal :result, window
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
        AePageObjects::Document.find
      end

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

      attempt_to_load_sequence = sequence('attempt_to_load')
      AePageObjects::Document.expects(:attempt_to_load).yields.in_sequence(attempt_to_load_sequence).returns(false)
      AePageObjects::Document.expects(:attempt_to_load).yields.in_sequence(attempt_to_load_sequence).returns(:found_it)

      block_calls = 0
      window = AePageObjects::Document.send(:find_window) do
        block_calls += 1
      end
      assert_equal :found_it, window

      assert_equal 2, block_calls
    end
  
    def test_find_window__not_found
      all_windows = [
        mock(:switch_to => true),
        mock(:switch_to => true),
        mock(:switch_to => true),
      ]

      AePageObjects::Window.expects(:all).returns(all_windows)

      attempt_to_load_sequence = sequence('attempt_to_load')
      AePageObjects::Document.expects(:attempt_to_load).in_sequence(attempt_to_load_sequence).returns(false)
      AePageObjects::Document.expects(:attempt_to_load).in_sequence(attempt_to_load_sequence).returns(false)
      AePageObjects::Document.expects(:attempt_to_load).in_sequence(attempt_to_load_sequence).returns(false)

      window = AePageObjects::Document.send(:find_window)
      assert_equal nil, window
    end

    def test_attempt_to_load
      AePageObjects::Document.expects(:new).returns(:instance)

      result = AePageObjects::Document.send(:attempt_to_load)
      assert_equal :instance, result
    end

    def test_attempt_to_load__extra_condition__success
      AePageObjects::Document.expects(:new).returns(:instance)

      result = AePageObjects::Document.send(:attempt_to_load) do
        true
      end
      assert_equal :instance, result
    end

    def test_attempt_to_load__extra_condition__fail
      AePageObjects::Document.expects(:new).returns(:instance)

      result = AePageObjects::Document.send(:attempt_to_load) do
        false
      end
      assert_equal nil, result
    end

    def test_attempt_to_load__loading_failed
      AePageObjects::Document.expects(:new).raises(AePageObjects::LoadingFailed.new)

      result = AePageObjects::Document.send(:attempt_to_load)
      assert_equal nil, result
    end

    def test_document
      kitty_class = ::AePageObjects::Document.new_subclass

      stub_current_window

      kitty_page = kitty_class.new
      
      assert_equal capybara_stub.session, kitty_page.node

      capybara_stub.session.expects(:current_url).returns("https://somejunk/yo/dude?as-if=homie")
      assert_equal "/yo/dude?as-if=homie", kitty_page.current_url

      capybara_stub.session.expects(:current_url).returns("https://somejunk/yo/dude?as-if=homie")
      assert_equal "/yo/dude", kitty_page.current_url_without_params
    end
    
    def test_find
      kitty_class = ::AePageObjects::Document.new_subclass

      stub_current_window

      kitty_page = kitty_class.new

      capybara_stub.session.expects(:find).with(1, 2).returns("result")
      assert_equal "result", kitty_page.find(1, 2)

      capybara_stub.session.expects(:find).with("hello kids").returns("result")
      kitty_page.find("hello kids")

      capybara_stub.session.expects(:find).with(:xpath, "yo").returns("result")
      kitty_page.find(:xpath, "yo")
    end
  end
end

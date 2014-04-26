require 'unit_helper'

module AePageObjects
  class PageLoaderTest < Test::Unit::TestCase

    def setup
      super

      @original_wait_time = Capybara.default_wait_time
      Capybara.default_wait_time = 0
    end

    def teardown
      Capybara.default_wait_time = @original_wait_time

      super
    end

    class DocumentClass1; end
    class DocumentClass2; end
    class DocumentClass3; end

    def test_default_document_class
      query    = mock(:conditions => [mock(:document_class => DocumentClass1), stub(:document_class => DocumentClass2)])
      strategy = mock

      loader = PageLoader.new(query, strategy)
      assert_equal DocumentClass1, loader.default_document_class

      # it's memoized
      assert_equal DocumentClass1, loader.default_document_class
    end

    def test_permitted_types_dump
      query    = mock(:conditions => [mock(:document_class => DocumentClass1), mock(:document_class => DocumentClass2)])
      strategy = mock

      loader = PageLoader.new(query, strategy)
      assert_equal ["AePageObjects::PageLoaderTest::DocumentClass1", "AePageObjects::PageLoaderTest::DocumentClass2"].inspect, loader.permitted_types_dump

      # it's memoized
      assert_equal ["AePageObjects::PageLoaderTest::DocumentClass1", "AePageObjects::PageLoaderTest::DocumentClass2"].inspect, loader.permitted_types_dump
    end

    def test_load_page
      query = stub(:conditions => [
        stub(:document_class => DocumentClass1),
        stub(:document_class => DocumentClass2)
      ])

      strategy = mock

      loader = PageLoader.new(query, strategy)

      Waiter.expects(:wait_for).yields

      strategy.expects(:load_page_with_condition).with(query.conditions.first).returns(nil)
      strategy.expects(:load_page_with_condition).with(query.conditions.last).returns(:page)

      page = loader.load_page
      assert_equal :page, page
    end

    def test_load_page__page_not_loaded_error
      query = stub(:conditions => [
        stub(:document_class => DocumentClass1),
        stub(:document_class => DocumentClass2),
        stub(:document_class => DocumentClass3)
      ])

      strategy = mock

      loader = PageLoader.new(query, strategy)

      sequence = sequence('sequence')
      strategy.expects(:load_page_with_condition).in_sequence(sequence).with(query.conditions[0]).returns(nil)
      strategy.expects(:load_page_with_condition).in_sequence(sequence).with(query.conditions[1]).returns(nil)
      strategy.expects(:load_page_with_condition).in_sequence(sequence).with(query.conditions[2]).returns(nil)

      error = RuntimeError.new("Hello")
      strategy.expects(:page_not_loaded_error).with(loader).returns(error)

      raised = assert_raise error.class do
        loader.load_page
      end

      assert_equal error, raised
    end

    def test_load_page__timeout
      query = stub(:conditions => [
        stub(:document_class => DocumentClass1),
        stub(:document_class => DocumentClass2)
      ])

      strategy = mock

      loader = PageLoader.new(query, strategy)

      Waiter.expects(:wait_for).multiple_yields(nil, nil)

      sequence = sequence('sequence')
      strategy.expects(:load_page_with_condition).in_sequence(sequence).with(query.conditions.first).returns(nil)
      strategy.expects(:load_page_with_condition).in_sequence(sequence).with(query.conditions.last).returns(nil)
      strategy.expects(:load_page_with_condition).in_sequence(sequence).with(query.conditions.first).returns(nil)
      strategy.expects(:load_page_with_condition).in_sequence(sequence).with(query.conditions.last).returns(nil)

      error = RuntimeError.new("")
      strategy.expects(:page_not_loaded_error).with(loader).returns(error)

      raised = assert_raise error.class do
        loader.load_page
      end

      assert_equal error, raised
    end
  end
end



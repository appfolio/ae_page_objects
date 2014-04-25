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

      strategy.expects(:load_page_with_condition).with(query.conditions.first).never
      strategy.expects(:load_page_with_condition).with(query.conditions.last).returns(:page)

      page = loader.load_page(DocumentClass2)
      assert_equal :page, page
    end

    def test_load_page__unexpected
      query = stub(:conditions => [
        stub(:document_class => DocumentClass1),
        stub(:document_class => DocumentClass2)
      ])

      strategy = mock

      loader = PageLoader.new(query, strategy)

      raised = assert_raise PageLoadError do
        loader.load_page(DocumentClass3)
      end

      assert_equal %Q{AePageObjects::PageLoaderTest::DocumentClass3 not expected. Allowed types: ["AePageObjects::PageLoaderTest::DocumentClass1", "AePageObjects::PageLoaderTest::DocumentClass2"]}, raised.message
    end

    def test_load_page__page_not_loaded_error
      query = stub(:conditions => [
        stub(:document_class => DocumentClass1),
        stub(:document_class => DocumentClass2),
        stub(:document_class => DocumentClass2)
      ])

      strategy = mock

      loader = PageLoader.new(query, strategy)

      strategy.expects(:load_page_with_condition).with(query.conditions[1]).returns(nil)
      strategy.expects(:load_page_with_condition).with(query.conditions[2]).returns(nil)

      error = RuntimeError.new("Hello")
      strategy.expects(:page_not_loaded_error).with(DocumentClass2, loader).returns(error)

      raised = assert_raise error.class do
        loader.load_page(DocumentClass2)
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

      strategy.expects(:load_page_with_condition).with(query.conditions.last).returns(nil).times(2)

      error = RuntimeError.new("")
      strategy.expects(:page_not_loaded_error).with(DocumentClass2, loader).returns(error)

      raised = assert_raise error.class do
        loader.load_page(DocumentClass2)
      end

      assert_equal error, raised
    end
  end
end



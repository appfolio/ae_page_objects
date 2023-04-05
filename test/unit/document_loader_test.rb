require 'unit_helper'

require 'ae_page_objects/document_loader'

module AePageObjects
  class DocumentLoaderTest < AePageObjectsTestCase

    def setup
      super

      capybara_stub
      @original_wait_time = default_max_wait_time
      self.default_max_wait_time = 0
    end

    def teardown
      self.default_max_wait_time = @original_wait_time

      super
    end

    class DocumentClass1; end
    class DocumentClass2; end
    class DocumentClass3; end

    def test_load_page
      query = stub("query", :conditions => [
        stub(:document_class => DocumentClass1),
        stub(:document_class => DocumentClass2)
      ])

      strategy = mock("strategy")

      loader = DocumentLoader.new(query, strategy)

      AePageObjects.expects(:wait_until).yields

      strategy.expects(:load_document_with_condition).with(query.conditions.first).returns(nil)
      strategy.expects(:load_document_with_condition).with(query.conditions.last).returns(:page)

      page = loader.load
      assert_equal :page, page
    end

    def test_load_page__document_not_loaded_error
      query = stub("query", :conditions => [
        stub(:document_class => DocumentClass1),
        stub(:document_class => DocumentClass2),
        stub(:document_class => DocumentClass3)
      ])

      strategy = mock("strategy")

      loader = DocumentLoader.new(query, strategy)

      sequence = sequence('sequence')
      strategy.expects(:load_document_with_condition).in_sequence(sequence).with(query.conditions[0]).returns(nil)
      strategy.expects(:load_document_with_condition).in_sequence(sequence).with(query.conditions[1]).returns(nil)
      strategy.expects(:load_document_with_condition).in_sequence(sequence).with(query.conditions[2]).returns(nil)

      strategy.expects(:document_not_loaded_error_message).with(query).returns("hello")

      raised = assert_raise DocumentLoadError do
        loader.load
      end

      assert_equal "hello", raised.message
    end

    def test_load_page__timeout
      query = stub("query", :conditions => [
        stub(:document_class => DocumentClass1),
        stub(:document_class => DocumentClass2)
      ])

      strategy = mock("strategy")

      loader = DocumentLoader.new(query, strategy)

      AePageObjects.expects(:wait_until).multiple_yields(nil, nil)

      sequence = sequence('sequence')
      strategy.expects(:load_document_with_condition).in_sequence(sequence).with(query.conditions.first).returns(nil)
      strategy.expects(:load_document_with_condition).in_sequence(sequence).with(query.conditions.last).returns(nil)
      strategy.expects(:load_document_with_condition).in_sequence(sequence).with(query.conditions.first).returns(nil)
      strategy.expects(:load_document_with_condition).in_sequence(sequence).with(query.conditions.last).returns(nil)

      strategy.expects(:document_not_loaded_error_message).with(query).returns("hello")

      raised = assert_raise DocumentLoadError do
        loader.load
      end

      assert_equal "hello", raised.message
    end

    private

    def default_max_wait_time=(val)
      if Capybara.respond_to?(:default_max_wait_time)
        Capybara.default_max_wait_time = val
      else
        Capybara.default_wait_time = val
      end
    end

    def default_max_wait_time
      if Capybara.respond_to?(:default_max_wait_time)
        Capybara.default_max_wait_time
      else
        Capybara.default_wait_time
      end
    end
  end
end



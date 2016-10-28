require 'unit_helper'

require 'ae_page_objects/single_window/same_window_loader_strategy'

require 'ae_page_objects/document_loader'
require 'ae_page_objects/document_proxy'
require 'ae_page_objects/document_query'

module AePageObjects
  module SingleWindow
    class SameWindowLoaderStrategyTest < AePageObjectsTestCase

      class DocumentClass
      end

      def test_load_page_with_condition__success
        DocumentClass.expects(:new).returns(:instance)

        condition = DocumentQuery::Condition.new(DocumentClass)
        condition.expects(:match?).with(:instance).returns(true)

        loader = SameWindowLoaderStrategy.new
        result = loader.load_document_with_condition(condition)
        assert_equal :instance, result
      end

      def test_load_page_with_condition__failure
        DocumentClass.expects(:new).returns(:instance)

        condition = DocumentQuery::Condition.new(DocumentClass)
        condition.expects(:match?).with(:instance).returns(false)

        loader = SameWindowLoaderStrategy.new
        result = loader.load_document_with_condition(condition)
        assert_equal nil, result
      end

      def test_load_page_with_condition__loading_element_failed
        DocumentClass.expects(:new).returns(:instance)

        condition = DocumentQuery::Condition.new(DocumentClass)
        condition.expects(:match?).with(:instance).raises(LoadingElementFailed)


        loader = SameWindowLoaderStrategy.new
        result = loader.load_document_with_condition(condition)
        assert_equal nil, result
      end

      def test_load_page_with_condition__loading_document_failed
        DocumentClass.expects(:new).raises(LoadingPageFailed.new)

        condition = DocumentQuery::Condition.new(DocumentClass)

        loader = SameWindowLoaderStrategy.new
        result = loader.load_document_with_condition(condition)
        assert_equal nil, result
      end

      def test_document_not_loaded_error_message
        loader = SameWindowLoaderStrategy.new
        query = mock(:permitted_types_dump => "permitted_types_dump")

        error_message = loader.document_not_loaded_error_message(query)

        assert_equal "Current window does not contain document with type in permitted_types_dump.", error_message
      end
    end
  end
end

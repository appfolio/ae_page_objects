require 'unit_helper'

module AePageObjects
  class DocumentLoader
    class SameWindowLoaderStrategyTest < Test::Unit::TestCase

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

      def test_load_page_with_condition__loading_failed
        DocumentClass.expects(:new).raises(AePageObjects::LoadingFailed.new)

        condition = DocumentQuery::Condition.new(DocumentClass)

        loader = SameWindowLoaderStrategy.new
        result = loader.load_document_with_condition(condition)
        assert_equal nil, result
      end

      def test_document_not_loaded_error
        loader = SameWindowLoaderStrategy.new
        page_loader = mock(:permitted_types_dump => "permitted_types_dump")

        error = loader.document_not_loaded_error(page_loader)

        assert_equal "Current window does not contain document with type in permitted_types_dump.", error.message
      end
    end
  end
end
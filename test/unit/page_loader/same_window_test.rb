require 'unit_helper'

module AePageObjects
  class PageLoader
    class SameWindowTest < Test::Unit::TestCase

      class DocumentClass
      end

      def test_load_page_with_condition__success
        DocumentClass.expects(:new).returns(:instance)

        condition = DocumentQuery::Condition.new(DocumentClass)
        condition.expects(:match?).with(:instance).returns(true)

        loader = SameWindow.new
        result = loader.load_page_with_condition(condition)
        assert_equal :instance, result
      end

      def test_load_page_with_condition__failure
        DocumentClass.expects(:new).returns(:instance)

        condition = DocumentQuery::Condition.new(DocumentClass)
        condition.expects(:match?).with(:instance).returns(false)

        loader = SameWindow.new
        result = loader.load_page_with_condition(condition)
        assert_equal nil, result
      end

      def test_load_page_with_condition__loading_failed
        DocumentClass.expects(:new).raises(AePageObjects::LoadingFailed.new)

        condition = DocumentQuery::Condition.new(DocumentClass)

        loader = SameWindow.new
        result = loader.load_page_with_condition(condition)
        assert_equal nil, result
      end

      def test_page_not_loaded_error
        loader = SameWindow.new
        page_loader = mock(:permitted_types_dump => "permitted_types_dump")

        error = loader.page_not_loaded_error(DocumentClass, page_loader)

        assert_equal "Failed instantiating a AePageObjects::PageLoader::SameWindowTest::DocumentClass in the current window from permitted_types_dump", error.message
      end

    end
  end
end
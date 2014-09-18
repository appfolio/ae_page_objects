require 'unit_helper'
module AePageObjects
  class DocumentProxyTest < Test::Unit::TestCase

    class DocumentClass
    end

    class DocumentClass2
    end

    def test_is_a
      page_loader = mock
      loaded_page = DocumentClass.new

      proxy = DocumentProxy.new(loaded_page, page_loader)

      assert_equal true,  proxy.is_a?(DocumentProxy)
      assert_equal true,  proxy.is_a?(DocumentClass)
      assert_equal false, proxy.is_a?(DocumentClass2)
    end

    def test_as_a
      page_loader = mock
      loaded_page = DocumentClass.new

      proxy = DocumentProxy.new(loaded_page, page_loader)

      assert_equal loaded_page, proxy.as_a(DocumentClass)
    end

    def test_as_a__error
      page_loader = mock(:permitted_types_dump => "permitted_types_dump")
      loaded_page = DocumentClass.new

      proxy = DocumentProxy.new(loaded_page, page_loader)

      raised = assert_raise CastError do
        proxy.as_a(DocumentClass2)
      end

      assert_equal "Loaded page is not a AePageObjects::DocumentProxyTest::DocumentClass2. Allowed pages: permitted_types_dump", raised.message
    end

    def test_methods_are_forwarded
      loaded_page = DocumentClass.new
      def loaded_page.hello_kitty
        :meow
      end

      query = mock
      query.expects(:default_document_class).times(3).returns(DocumentClass)

      proxy = DocumentProxy.new(loaded_page, query)
      assert_equal :meow, proxy.hello_kitty

      # memoized
      assert_equal :meow, proxy.hello_kitty

      # not defined not forwarded
      assert_raises NoMethodError do
        proxy.bark_bark
      end
    end
  end
end

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

      raised = assert_raise DocumentLoadError do
        proxy.as_a(DocumentClass2)
      end

      assert_equal "AePageObjects::DocumentProxyTest::DocumentClass2 not expected. Allowed types: permitted_types_dump", raised.message
    end

    def test_methods_are_forwarded
      loaded_page = Class.new(DocumentClass) do
        def hello_kitty
          :meow
        end
      end.new

      page_loader = mock
      page_loader.expects(:default_document_class).returns(DocumentClass)

      proxy = DocumentProxy.new(loaded_page, page_loader)
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

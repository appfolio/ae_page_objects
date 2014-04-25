require 'unit_helper'

module AePageObjects
  class DocumentProxyTest < Test::Unit::TestCase

    def test_is_a
      document_class = Class.new

      page_loader = mock
      loaded_page = mock
      page_loader.expects(:load_page).with(document_class).returns(loaded_page)

      proxy = DocumentProxy.new(page_loader)

      assert proxy.is_a?(DocumentProxy)
      assert proxy.is_a?(document_class)
    end

    def test_is_a__false
      document_class = Class.new

      page_loader = mock
      page_loader.expects(:load_page).with(document_class).returns(false)

      proxy = DocumentProxy.new(page_loader)

      assert proxy.is_a?(DocumentProxy)
      assert_equal false, proxy.is_a?(document_class)
    end

    def test_is_a__error
      document_class = Class.new

      page_loader = mock
      page_loader.expects(:load_page).with(document_class).raises(AePageObjects::Error.new)

      proxy = DocumentProxy.new(page_loader)

      assert proxy.is_a?(DocumentProxy)
      assert_equal false, proxy.is_a?(document_class)
    end

    def test_as_a
      document_class = Class.new

      page_loader = mock
      loaded_page = mock
      page_loader.expects(:load_page).with(document_class).returns(loaded_page)

      proxy = DocumentProxy.new(page_loader)
      assert_equal loaded_page, proxy.as_a(document_class)
    end

    def test_as_a__error
      document_class = Class.new

      error = AePageObjects::PageLoadError.new

      page_loader = mock
      page_loader.expects(:load_page).with(document_class).raises(error)

      proxy = DocumentProxy.new(page_loader)

      raised = assert_raise error.class do
        proxy.as_a(document_class)
      end

      assert_equal error, raised
    end

    def test_methods_are_forwarded
      default_document_class = Class.new do
        def hello_kitty
          :meow
        end
      end

      page_loader = mock
      page_loader.expects(:default_document_class).returns(default_document_class)
      page_loader.expects(:load_page).with(default_document_class).returns(default_document_class.new)

      proxy = DocumentProxy.new(page_loader)
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

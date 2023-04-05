require 'unit_helper'

require 'ae_page_objects/multiple_windows/browser'
require 'ae_page_objects/multiple_windows/cross_window_loader_strategy'

require 'ae_page_objects/document_loader'
require 'ae_page_objects/document_proxy'
require 'ae_page_objects/document_query'

module AePageObjects
  module MultipleWindows
    class BrowserTest < AePageObjectsTestCase
      def test_find_document
        document_class = Class.new(AePageObjects::Document)

        the_block = proc do
        end

        browser = Browser.new
        browser.windows.expects(:current_window).returns(:current_window)

        document_loader = mock("document_loader")
        document_loader.expects(:load).returns(:loaded_page)

        query =  nil
        strategy = nil

        DocumentLoader.expects(:new).with do |q, ls|
          query = q
          strategy = ls

          query.is_a?(DocumentQuery) && strategy.is_a?(CrossWindowLoaderStrategy)
        end.returns(document_loader)

        proxy = browser.find_document(document_class, :ignore_current => true, &the_block)

        assert_equal true,        proxy.is_a?(DocumentProxy)
        assert_equal :loaded_page, proxy.instance_variable_get(:@loaded_page)

        query_conditions = query.conditions
        assert_equal 1, query_conditions.size

        condition = query_conditions.first
        assert_equal document_class, condition.document_class
        assert_equal true, condition.document_conditions[:ignore_current]
        assert_equal the_block, condition.document_conditions[:block]

        assert_equal CrossWindowLoaderStrategy, strategy.class

        window_list = strategy.instance_variable_get(:@window_list)
        assert_equal browser.windows, window_list
      end
    end
  end
end

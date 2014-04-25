require 'unit_helper'

module AePageObjects
  class BrowserTest < Test::Unit::TestCase

    def test_find_document
      document_class = Class.new(AePageObjects::Document)

      the_block = proc do
      end

      browser = Browser.new
      browser.windows.expects(:current_window).returns(:current_window)

      proxy = browser.find_document(document_class, :ignore_current => true, &the_block)

      assert_equal true, proxy.is_a?(DocumentProxy)

      page_loader = proxy.instance_variable_get(:@page_loader)
      assert_equal PageLoader, page_loader.class

      query = page_loader.instance_variable_get(:@query)
      assert_equal DocumentQuery, query.class

      query_conditions = query.conditions
      assert_equal 1, query_conditions.size

      condition = query_conditions.first
      assert_equal document_class, condition.document_class
      assert_equal true, condition.page_conditions[:ignore_current]
      assert_equal the_block, condition.page_conditions[:block]

      strategy = page_loader.instance_variable_get(:@strategy)
      assert_equal PageLoader::CrossWindow, strategy.class

      window_list = strategy.instance_variable_get(:@window_list)
      assert_equal browser.windows, window_list
    end
  end
end

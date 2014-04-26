require 'unit_helper'

module AePageObjects
  class BrowserTest < Test::Unit::TestCase

    def test_find_document
      document_class = Class.new(AePageObjects::Document)

      the_block = proc do
      end

      browser = Browser.new
      browser.windows.expects(:current_window).returns(:current_window)

      page_loader = mock
      page_loader.expects(:load_page).returns(:loaded_page)

      query =  nil
      strategy = nil

      PageLoader.expects(:new).with do |q, ls|
        query = q
        strategy = ls

        query.is_a?(DocumentQuery) && strategy.is_a?(PageLoader::CrossWindow)
      end.returns(page_loader)

      proxy = browser.find_document(document_class, :ignore_current => true, &the_block)

      assert_equal true,        proxy.is_a?(DocumentProxy)
      assert_equal page_loader, proxy.instance_variable_get(:@page_loader)

      query_conditions = query.conditions
      assert_equal 1, query_conditions.size

      condition = query_conditions.first
      assert_equal document_class, condition.document_class
      assert_equal true, condition.page_conditions[:ignore_current]
      assert_equal the_block, condition.page_conditions[:block]

      assert_equal PageLoader::CrossWindow, strategy.class

      window_list = strategy.instance_variable_get(:@window_list)
      assert_equal browser.windows, window_list
    end
  end
end

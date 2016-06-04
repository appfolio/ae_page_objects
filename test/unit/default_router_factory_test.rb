require 'unit_helper'

module AePageObjects
  class DefaultRouterFactoryTest < AePageObjectsTestCase

    def test_router_for__no_site
      factory = DefaultRouterFactory.new

      document_class = Class.new
      router = factory.router_for(document_class)

      assert_kind_of AePageObjects::ApplicationRouter, router
    end

    def test_router_for__with_site
      factory = DefaultRouterFactory.new

      document_class = Class.new
      site = mock(router: :router)
      Site.expects(:from).with(document_class).returns(site)
      factory.expects(:warn)

      router = factory.router_for(document_class)

      assert_equal :router, router
    end
  end
end

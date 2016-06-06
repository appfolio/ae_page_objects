require 'unit_helper'

module AePageObjects
  class DefaultRouterFactoryTest < AePageObjectsTestCase

    def test_router_for
      factory = DefaultRouterFactory.new

      document_class = Class.new
      router = factory.router_for(document_class)

      assert_kind_of AePageObjects::BasicRouter, router
    end
  end
end

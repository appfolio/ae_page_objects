require 'ae_page_objects/core/application_router'

module AePageObjects
  class RailsRouterFactory
    def router_for(document_class)
      @router ||= AePageObjects::ApplicationRouter.new
    end
  end
end

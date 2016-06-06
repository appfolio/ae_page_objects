require 'ae_page_objects/core/basic_router'

module AePageObjects
  class DefaultRouterFactory

    def router_for(document_class)
      @router ||= AePageObjects::BasicRouter.new
    end
  end
end

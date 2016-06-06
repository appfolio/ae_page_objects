require 'ae_page_objects/deprecated_site/site'
require 'ae_page_objects/core/basic_router'

module AePageObjects
  class DefaultRouterFactory

    def router_for(document_class)
      site = Site.from(document_class)

      if site
        warn <<-MESSAGE
[DEPRECATION WARNING]: AePageObjects::Site will be removed in AePageObjects 3.0.
                       AePageObjects::Document subclasses now look for routers. You
                       set the router via AePageObjects::Document.router or by implementing
                       a router factory and setting AePageObjects.router_factory.
        MESSAGE
        site.router
      else
        AePageObjects::BasicRouter.new
      end
    end
  end
end

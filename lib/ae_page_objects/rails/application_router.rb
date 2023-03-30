require 'ae_page_objects/core/basic_router'

module AePageObjects
  class ApplicationRouter < BasicRouter

    # This whole file is a kludge and probably belongs in an ae_page_objects-rails extension

    module Recognizer

      class Base
        def generate_path(named_route, *args)
          if routes.respond_to?("#{named_route}_path")
            routes.send("#{named_route}_path", *args)
          end
        end

        def recognizes?(named_route, url)
          url = normalize_url(url)

          resolved_named_route = resolve_named_route(named_route)

          [:get, :post, :put, :delete, :patch].each do |method|
            resolved_route_from_url = resolve_url(url, method)

            # The first resolved route matching named route is returned as
            # Rails' routes are in priority order.
            if resolved_named_route == resolved_route_from_url
              return true
            end
          end

          false
        end

      private

        def routes
          raise NotImplementedError, "You must implement routes"
        end

        def normalize_url(url)
          raise NotImplementedError, "You must implement normalize_url"
        end

        def router
          raise NotImplementedError, "You must implement router"
        end

        def resolve_named_route(named_route)
          requirements = router.named_routes[named_route].requirements
          ResolvedRoute.new(requirements[:controller], requirements[:action])
        end

        def resolve_url(url, method)
          recognized_path = router.recognize_path(url, {:method => method})
          ResolvedRoute.new(recognized_path[:controller], recognized_path[:action])
        rescue ActionController::RoutingError, ActionController::MethodNotAllowed
        end

        ResolvedRoute = Struct.new(:controller, :action)
      end

      class Rails3 < Base

      private

        def request_for(url, method)
          ::Rails.application.routes.request_class.new(env_for(url, method))
        end

        def env_for(url, method)
          begin
            Rack::MockRequest.env_for(url, {:method => method})
          rescue URI::InvalidURIError => e
            raise ActionController::RoutingError, e.message
          end
        end

        def normalize_url(url)
          Rack::Mount::Utils.normalize_path(url) unless url =~ %r{://}
        end

        def router
          ::Rails.application.routes
        end

        def routes
          @routes ||= begin
            routes_class = Class.new do
              include ::Rails.application.routes.url_helpers
            end
            routes_class.new
          end
        end
      end

      class Rails32 < Rails3

      private

        def normalize_url(url)
          Journey::Router::Utils.normalize_path(url) unless url =~ %r{://}
        end
      end

      class Rails4Plus < Rails32

      private

        def normalize_url(url)
          require 'action_dispatch/journey'
          ActionDispatch::Journey::Router::Utils.normalize_path(url) unless url =~ %r{://}
        end
      end
    end

    def path_recognizes_url?(path, url)
      if path.is_a?(Symbol)
        recognizer.recognizes?(path, url)
      else
        super
      end
    end

    def generate_path(named_route, *args)
      if named_route.is_a?(Symbol)
        recognizer.generate_path(named_route, *args)
      else
        super
      end
    end

    private

    def recognizer
      @recognizer ||= case ::Rails.gem_version
        when Gem::Requirement.new('>= 3.0', '< 3.2')
          Recognizer::Rails3.new
        when Gem::Requirement.new('~> 3.2')
          Recognizer::Rails32.new
        when Gem::Requirement.new('>= 4.0', '< 8.0')
          Recognizer::Rails4Plus.new
        else
          warn "[WARNING]: AePageObjects is not tested against Rails #{::Rails.version} and may behave in an undefined manner."
          Recognizer::Rails4Plus.new
      end
    end
  end
end

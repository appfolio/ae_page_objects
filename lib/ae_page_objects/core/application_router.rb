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

        def normalize_url(url)
          raise NotImplementedError, "You must implement normalize_url"
        end

        def router
          raise NotImplementedError, "You must implement router"
        end

        def recognizes?(named_route, url)
          url = normalize_url(url)

          resolved_named_route = resolve_named_route(named_route)

          http_verbs.each do |method|
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

        def http_verbs
          [:get, :post, :put, :delete, :patch]
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

        class ResolvedRoute < Struct.new(:controller, :action)
          def == (o)
            controller == o.controller &&
              action == o.action
          end
        end
      end

      class Rails23 < Base

      private

        def routes
          @routes ||= begin
            routes_class = Class.new do
              include ActionController::UrlWriter
            end
            ActionController::Routing::Routes.install_helpers(routes_class)
            routes_class.new
          end
        end

        def normalize_url(url)
          url
        end

        def router
          ActionController::Routing::Routes
        end
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

      class Rails4 < Rails32

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
      @recognizer ||= begin
        if ::Rails.version =~ /\A2\.3/
          Recognizer::Rails23.new
        elsif ::Rails.version =~ /\A3\.[01]/
          Recognizer::Rails3.new
        elsif ::Rails.version =~ /\A3\.2/
          Recognizer::Rails32.new
        elsif ::Rails.version =~ /\A4\.[01]/
          Recognizer::Rails4.new
        else
          warn "[WARNING]: AePageObjects is not tested against Rails #{::Rails.version} and may behave in an undefined manner."
          Recognizer::Rails4.new
        end
      end
    end
  end
end

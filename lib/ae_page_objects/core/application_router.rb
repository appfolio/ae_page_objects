module AePageObjects
  class ApplicationRouter < BasicRouter

    # This whole file is a kludge and probably belongs in an ae_page_objects-rails extension

    module Recognizer

      class Base
        def generate_path(named_route, *args)
          begin
            routes.send("#{named_route}_path", *args)
          rescue NoMethodError
            nil
          end
        end
      end

      class Rails23 < Base
        def recognizes?(path, url)
          path_route_result = ActionController::Routing::Routes.named_routes[path].requirements
          recognized_result = nil
          router = ActionController::Routing::Routes

          ["GET", "PUT", "POST", "DELETE", "PATCH"].map(&:downcase).map(&:to_sym).each do |method|
            begin
              recognized_result = router.recognize_path(url, {:method => method}).select do
              |key, _|
                key.to_s.match(/(controller|action)/)
              end
            rescue ActionController::RoutingError, ActionController::MethodNotAllowed
            end

            # Only the first recognized path returned by Rails is considered,
            # which means, we only want highest prioritized route.
            if recognized_result && path_route_result == Hash[recognized_result]
              return true
            else
              next
            end
          end

          false
        end

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
      end

      class Rails3 < Base
        def recognizes?(path, url)
          url, router = url_and_router(url)
          path_route_result = get_path_route_result(router, path) #router.named_routes[path.to_s].defaults
          recognized_result = nil

          ["GET", "PUT", "POST", "DELETE", "PATCH"].each do |method|
            begin
              recognized_result = router.recognize_path(url, {:method => method}).select do
              |key, _|
                key.to_s.match(/(controller|action)/)
              end
            rescue ActionController::RoutingError, ActionController::MethodNotAllowed
            end

            # Only the first recognized path returned by Rails is considered,
            # which means, we only want highest prioritized route.
            if recognized_result && path_route_result == Hash[recognized_result]
              return true
            else
              next
            end
          end
          false
        end

      private

        def get_path_route_result(router, path)
          path_route_result = router.named_routes[path.to_s]

          if path_route_result
            return path_route_result.defaults
          else
            #The main app didn't have the path, try the engines.
            engine, engine_route = path.to_s.split("__")
            router.named_routes[engine].app.instance.routes.named_routes[engine_route].defaults
          end
        end

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

        def url_and_router(url)
          url = Rack::Mount::Utils.normalize_path(url) unless url =~ %r{://}
          router = ::Rails.application.routes

          [url, router]
        end

        def routes
          @routes ||= begin
            routes_class = Class.new do
              include ::Rails.application.routes.url_helpers

              def method_missing(name, *args, &block)
                engine, named_route = name.to_s.split("__")
                engine_const = engine.split("_").map(&:camelize).join("::")

                Rails::Application::Railties.engines.detect do |engine|
                  engine.class.to_s == engine_const
                end.routes.url_helpers.send(named_route)
              end
            end
            routes_class.new
          end
        end
      end

      class Rails32 < Rails3

      private

        def url_and_router(url)
          url = Journey::Router::Utils.normalize_path(url) unless url =~ %r{://}
          router = ::Rails.application.routes

          def router.recognize_path(url, options={})
            begin
              super(url, options)
            rescue ActionController::RoutingError => e
              _, engine, _ = url.split("/")
              url_for_engine = url.gsub(%r(^/#{engine}), '')
              engine_const = "#{engine.capitalize}::Engine"

              found_engine = Rails::Application::Railties.engines.detect do |engine|
                engine.class.to_s == engine_const
              end

              if found_engine
                found_engine.routes.recognize_path(url_for_engine, options)
              else
                raise ActionController::RoutingError, e.message
              end
            end
          end

          [url, router]
        end
      end

      class Rails4 < Rails32

      private

        def url_and_router(url)
          require 'action_dispatch/journey'
          url = ActionDispatch::Journey::Router::Utils.normalize_path(url) unless url =~ %r{://}
          router = ::Rails.application.routes

          def router.recognize_path(url, options={})
            begin
              super(url, options)
            rescue ActionController::RoutingError => e
              _, engine, _ = url.split("/")
              url_for_engine = url.gsub(%r(^/#{engine}), '')
              engine_const = "#{engine.capitalize}::Engine"

              found_engine = Rails::Application::Railties.engines.detect do |engine|
                engine.class.to_s == engine_const
              end

              if found_engine
                found_engine.routes.recognize_path(url_for_engine, options)
              else
                raise ActionController::RoutingError, e.message
              end
            end
          end

          [url, router]
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

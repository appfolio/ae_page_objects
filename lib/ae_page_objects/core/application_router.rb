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
      end

      class Rails23 < Base
        def recognizes?(path, url)
          ["GET", "PUT", "POST", "DELETE", "PATCH"].map(&:downcase).map(&:to_sym).each do |method|
            route = ActionController::Routing::Routes.named_routes[path]
            route.recognize(url, {:method => method})

            return true if route && route.recognize(url, {:method => method})
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

          ["GET", "PUT", "POST", "DELETE", "PATCH"].each do |method|
            router.recognize(request_for(url, method)) do |route, matches, params|
              return true if route.name.to_s == path.to_s
            end
          end

          false
        end


      private

        def request_for(url, method)
          Rails.application.routes.request_class.new(env_for(url, method))
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
          router = Rails.application.routes.set

          [url, router]
        end

        def routes
          @routes ||= begin
            routes_class = Class.new do
              include Rails.application.routes.url_helpers
            end
            routes_class.new
          end
        end
      end

      class Rails32 < Rails3

      private
        def url_and_router(url)
          url = Journey::Router::Utils.normalize_path(url) unless url =~ %r{://}
          router = Rails.application.routes.router

          [url, router]
        end
      end

      class Rails4 < Rails32

        private
        def url_and_router(url)
          require 'action_dispatch/journey'
          url = ActionDispatch::Journey::Router::Utils.normalize_path(url) unless url =~ %r{://}
          router = Rails.application.routes.router

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
        if Rails.version =~ /\A2\.3/
          Recognizer::Rails23.new
        elsif Rails.version =~ /\A3\.[01]/
          Recognizer::Rails3.new
        elsif Rails.version =~ /\A3\.2/
          Recognizer::Rails32.new
        elsif Rails.version =~ /\A4\.[01]/
          warn "[WARNING]: AePageObjects works but is not thoroughly tested against Rails 4. Caveat emptor."
          Recognizer::Rails4.new
        else
          warn "[WARNING]: AePageObjects is not tested against Rails #{Rails.version} and may behave in an undefined manner."
          Recognizer::Rails32.new
        end
      end
    end
  end
end

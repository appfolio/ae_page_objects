module AePageObjects
  class ApplicationRouter

    module Recognizer

      class Base

      end

      class Rails23
        def recognizes?(path, url)
          url, router = url_and_router(url)

          ["GET", "PUT", "POST", "DELETE", "PATCH"].each do |method|
            begin
              return true if router.recognize(request_for(url, method))# do |route, matches, params|
              #  return true if route.name.to_s == path.to_s
              #end
            rescue ActionController::MethodNotAllowed, ActionController::UnknownHttpMethod
              # ignore
            end
          end

          false
        end

        def generate_path(named_route, *args)
          if routes.respond_to?("#{named_route}_path")
            routes.send("#{named_route}_path", *args)
          end
        end

      private

        def url_and_router(url)
          #url = Rack::Mount::Utils.normalize_path(url) unless url =~ %r{://}
          router = ActionController::Routing::Routes

          [url, router]
        end

        def routes
          @routes ||= begin
            routes_class = Class.new do
              include ActionController::UrlWriter
            end
            ActionController::Routing::Routes.install_helpers(routes_class)
            routes_class.new
          end
        end

        def request_for(url, method)
          url = "/#{url}" unless url.first == '/'

          ActionController::TestRequest.new.tap do |request|
            request.env["REQUEST_METHOD"] = method.to_s.upcase
            request.path = url
          end
        end
      end

      class Rails3
        def recognizes?(path, url)
          url, router = url_and_router(url)

          ["GET", "PUT", "POST", "DELETE", "PATCH"].each do |method|
            router.recognize(request_for(url, method)) do |route, matches, params|
              return true if route.name.to_s == path.to_s
            end
          end

          false
        end

        def generate_path(named_route, *args)
          if routes.respond_to?("#{named_route}_path")
            routes.send("#{named_route}_path", *args)
          end
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
    end

    def path_recognizes_url?(path, url)
      if path.is_a?(String)
        path.sub(/\/$/, '') == url.sub(/\/$/, '')
      elsif path.is_a?(Symbol)
        recognizer.recognizes?(path, url)
      end
    end

    def generate_path(named_route, *args)
      if named_route.is_a?(String)
        named_route
      else
        recognizer.generate_path(named_route, *args)
      end
    end

  private

    def recognizer
      @recognizer ||= begin
        if Rails.version =~ /^2\.3/
          Recognizer::Rails23.new
        elsif Rails.version =~ /^3\.[01]/
          Recognizer::Rails3.new
        elsif Rails.version =~ /^3\.2/
          Recognizer::Rails32.new
        else
          warn "[WARNING]: AePageObjects is not tested against Rails #{Rails.version} and may behave in an undefined manner."
          Recognizer::Rails32.new
        end
      end
    end
  end
end

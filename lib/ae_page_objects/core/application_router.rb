module AePageObjects
  class ApplicationRouter
    def path_recognizes_url?(path, url)
      if path.is_a?(String)
        path.sub(/\/$/, '') == url.sub(/\/$/, '')
      elsif path.is_a?(Symbol)
        url, router = url_and_router(url)

        ["GET", "PUT", "POST", "DELETE", "PATCH"].each do |method|
          router.recognize(request_for(url, method)) do |route, matches, params|
            return true if route.name.to_s == path.to_s
          end
        end
        false
      end
    end

    def generate_path(named_route, *args)
      return named_route if named_route.is_a?(String)

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
      if Rails.version =~ /^3.[01]/ 
        url = Rack::Mount::Utils.normalize_path(url) unless url =~ %r{://}
        router = Rails.application.routes.set
      else
        url = Journey::Router::Utils.normalize_path(url) unless url =~ %r{://}
        router = Rails.application.routes.router
      end
      
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
end

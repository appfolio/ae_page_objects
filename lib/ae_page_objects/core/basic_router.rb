module AePageObjects
  class BasicRouter
    def path_recognizes_url?(path, url)
      path.sub(/\/$/, '') == url.sub(/\/$/, '')
    end

    def generate_path(named_route, *args)
      named_route
    end
  end
end

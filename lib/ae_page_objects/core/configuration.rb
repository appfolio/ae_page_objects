require 'rails/paths'

module AePageObjects
  class Configuration
    attr_writer :router
    
    def initialize(application, root)
      @application = application
      @root        = root
    end

    def paths
      @paths ||= begin
        paths = Rails::Paths::Root.new(@root)
        paths.add "test/page_objects", :eager_load => true
        paths
      end
    end
    
    def eager_load_paths
      @eager_load_paths ||= paths.eager_load
    end
    
    def autoload_paths
      @autoload_paths ||= paths.autoload_paths
    end
    
    def router
      @router ||= ApplicationRouter.new
    end
  end
end


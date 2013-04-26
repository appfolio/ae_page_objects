module AePageObjects
  class Configuration
    attr_writer :router
    
    def initialize(application)
      @application = application
    end

    def eager_load_paths
      @eager_load_paths ||= ["test/page_objects"]
    end
    
    def router
      @router ||= ApplicationRouter.new
    end
  end
end


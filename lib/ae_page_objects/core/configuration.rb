module AePageObjects
  class Configuration
    attr_accessor :router, :root_path
    
    def initialize(application)
      @application = application
      @root_path   = application.class.called_from
    end

    def router
      @router ||= ApplicationRouter.new
    end
  end
end


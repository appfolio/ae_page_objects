module AePageObjects
  class Configuration
    attr_accessor :router, :paths
    
    def initialize(application)
      @application = application
      @paths       = [application.class.called_from]
    end

    def router
      @router ||= ApplicationRouter.new
    end
  end
end


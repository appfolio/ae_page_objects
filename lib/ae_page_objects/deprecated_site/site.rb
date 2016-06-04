require 'ae_page_objects/deprecated_site/module_extension'
require 'ae_page_objects/deprecated_site/singleton'
require 'ae_page_objects/deprecated_site/universe'

module AePageObjects
  class Site
    extend AePageObjects::Singleton

    class << self
      private :new

      def initialize!
        instance.initialize!
      end

      def router=(router)
        instance.router = router
      end

      def inherited(site_class)
        warn <<-MESSAGE
[DEPRECATION WARNING]: AePageObjects::Site will be removed in AePageObjects 3.0.
                       AePageObjects::Document subclasses now look for routers. You
                       set the router via AePageObjects::Document.router or by implementing
                       a router factory and setting AePageObjects.router_factory.
Called from: #{caller.first}
        MESSAGE

        super

        site_class.universe.send(:include, Universe)
        site_class.universe.page_objects_site_class = site_class
      end

      def universe
        parent
      end

      def from(from_mod)
        until from_mod == Object
          if from_mod < Universe
            return from_mod.page_objects_site_class.instance
          end

          from_mod = from_mod.parent
        end

        nil
      end
    end

    attr_writer :router

    def universe
      self.class.universe
    end

    def path_recognizes_url?(*args)
      self.router.path_recognizes_url?(*args)
    end

    def generate_path(*args)
      self.router.generate_path(*args)
    end

    def router
      @router ||= begin
        require 'ae_page_objects/core/application_router'
        ApplicationRouter.new
      end
    end

    def initialize!
    end
  end
end

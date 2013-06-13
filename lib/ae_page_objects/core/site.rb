module AePageObjects
  class Site
    extend AePageObjects::Singleton

    class << self
      private :new

      attr_accessor :current_document

      def initialize!
        instance.initialize!
      end

      def router=(router)
        instance.router = router
      end

      def inherited(site_class)
        super

        site_class.universe.send(:include, Universe)
        site_class.universe.page_objects_site_class = site_class
      end

      def universe
        parent
      end

      def from(from_mod)
        until from_mod == Object
          if from_mod < AePageObjects::Universe
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
      @router ||= ApplicationRouter.new
    end

    def initialize!
    end
  end
end

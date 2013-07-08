module AePageObjects
  class Application
    extend AePageObjects::Singleton
      
    class << self
      private :new

      delegate :initialize!, :router=, :to => :instance

      def inherited(application_class)
        super

        application_class.universe.send(:include, Universe)
        application_class.universe.page_objects_application_class = application_class
      end

      def universe
        parent
      end

      def from(from_mod)
        until from_mod == Object
          if from_mod < AePageObjects::Universe
            return from_mod.page_objects_application_class.instance
          end

          from_mod = from_mod.parent
        end

        nil
      end
    end

    attr_writer :router

    delegate :universe, :to => 'self.class'

    delegate :path_recognizes_url?, :to => :router
    delegate :generate_path,        :to => :router

    def router
      @router ||= ApplicationRouter.new
    end

    def initialize!
    end
  end
end

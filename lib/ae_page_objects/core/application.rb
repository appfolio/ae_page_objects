module AePageObjects
  class Application
    include AePageObjects::Singleton
      
    class << self
      private :new

      attr_accessor :called_from

      delegate :initialize!, :to => :instance
      delegate :config,      :to => :instance

      def inherited(application_class)
        super

        application_class.called_from = begin
          call_stack = caller.map { |p| p.sub(/:\d+.*/, '') }
          File.dirname(call_stack.detect { |p| p !~ %r[railties[\w.-]*/lib/rails|rack[\w.-]*/lib/rack] })
        end

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

    delegate :universe, :to => 'self.class'

    delegate :paths,  :to => :config
    delegate :router, :to => :config

    delegate :path_recognizes_url?, :to => :router
    delegate :generate_path,        :to => :router

    def config
      @config ||= Configuration.new(self)
    end

    def initialize!
      ActiveSupport::Dependencies.autoload_paths.unshift(*paths)
      eager_load!
    end

    def resolve_constant(from_mod, const_name)
      resolver = ConstantResolver.new(self, from_mod, const_name)

      resolved = nil
      paths.each do |path|
        break if resolved = resolver.load_constant_from_path(path)
      end
      resolved
    end

  private

    def eager_load!
      paths.each do |path|
        matcher = /\A#{Regexp.escape(path)}\/(.*)\.rb\Z/

        Dir.glob("#{path}/**/*.rb").sort.each do |file|
          dependency_name = file.sub(matcher, '\1')
          require_dependency dependency_name
        end
      end
    end
  end
end

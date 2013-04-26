module AePageObjects
  class Application
    include Configurable
      
    class << self
      private :new

      delegate :initialize!, :to => :instance

      def inherited(application_class)
        super
        application_class.parent.send(:include, ConstantResolver)
      end
    end

    delegate :router, :to => :config
    delegate :path_recognizes_url?, :to => :router
    delegate :generate_path, :to => :router

    def initialize
      ActiveSupport::Dependencies.autoload_paths.unshift(*all_autoload_paths)

      # Freeze so future modifications will fail rather than do nothing mysteriously
      config.eager_load_paths.freeze
    end

    def config
      @config ||= Configuration.new(self)
    end

    def initialize!
      eager_load!
    end

    def all_autoload_paths
      @all_autoload_paths ||= config.eager_load_paths.uniq
    end

  private

    def eager_load!
      config.eager_load_paths.each do |load_path|
        matcher = /\A#{Regexp.escape(load_path)}\/(.*)\.rb\Z/

        Dir.glob("#{load_path}/**/*.rb").sort.each do |file|
          dependency_name = file.sub(matcher, '\1')
          require_dependency dependency_name
        end
      end
    end
  end
end

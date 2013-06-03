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

        application_class.parent.send(:include, ConstantResolver)
        application_class.parent.page_objects_application = application_class
      end
    end

    delegate :root_path, :to => :config

    delegate :router, :to => :config
    delegate :path_recognizes_url?, :to => :router
    delegate :generate_path, :to => :router

    def config
      @config ||= Configuration.new(self)
    end

    def initialize!
      ActiveSupport::Dependencies.autoload_paths.unshift(root_path)
      eager_load!
    end

  private

    def eager_load!
      matcher = /\A#{Regexp.escape(root_path)}\/(.*)\.rb\Z/

      Dir.glob("#{root_path}/**/*.rb").sort.each do |file|
        dependency_name = file.sub(matcher, '\1')
        require_dependency dependency_name
      end
    end
  end
end

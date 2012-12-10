require "active_support/dependencies"

module AePageObjects
  class Application
    include Configurable
      
    class << self
      attr_accessor :called_from
      private :new

      def inherited(base)
        super
        
        base.called_from = begin
          call_stack = caller.map { |p| p.sub(/:\d+.*/, '') }
          File.dirname(call_stack.detect { |p| p !~ %r[railties[\w.-]*/lib/rails|rack[\w.-]*/lib/rack] })
        end
        
        base.parent.send(:include, ConstantResolver)
      end
      
      def initialize!
        instance.initialize!
      end
    end
    
    def initialize
      set_autoload_paths
    end

    def config
      @config ||= Configuration.new(self, find_root_with_flag("config.ru", Dir.pwd))
    end

    def initialize!
      eager_load!
    end
    
    delegate :path_recognizes_url?, :to => :router
    delegate :generate_path, :to => :router
    
    def all_autoload_paths
      @all_autoload_paths ||= (config.autoload_paths + config.eager_load_paths).uniq
    end
    
  private
  
    def router
      @router ||= config.router
    end
    
    def set_autoload_paths
      ActiveSupport::Dependencies.autoload_paths.unshift(*all_autoload_paths)

      # Freeze so future modifications will fail rather than do nothing mysteriously
      config.autoload_paths.freeze
      config.eager_load_paths.freeze
    end

    def eager_load!
      config.eager_load_paths.each do |load_path|
        matcher = /\A#{Regexp.escape(load_path)}\/(.*)\.rb\Z/

        Dir.glob("#{load_path}/**/*.rb").sort.each do |file|
          dependency_name = file.sub(matcher, '\1')
          require_dependency dependency_name
        end
      end
    end

    def find_root_with_flag(flag, default=nil)
      root_path = self.class.called_from

      while root_path && File.directory?(root_path) && !File.exist?("#{root_path}/#{flag}")
        parent = File.dirname(root_path)
        root_path = parent != root_path && parent
      end

      root = File.exist?("#{root_path}/#{flag}") ? root_path : default
      raise "Could not find root path for #{self}" unless root
      
      Pathname.new(root).realpath
    end
  end
end

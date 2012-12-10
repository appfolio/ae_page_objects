module AePageObjects
  class PathNotResolvable < StandardError
  end
  
  module Visitable
    extend ActiveSupport::Concern
    
  private
    
    def ensure_loaded!
      unless self.class.can_load_from_current_url?
        raise LoadingFailed, "#{self.class.name} cannot be loaded with url '#{current_url_without_params}'"
      end
      
      super
    end
    
    module VisitMethod
      def visit(*args)
        raise ArgumentError, "Cannot pass block to visit()" if block_given?

        full_path = application.generate_path(paths.first, *args)
        raise PathNotResolvable, "#{self.name} not visitable via #{paths.first}(#{args.inspect})" unless full_path

        Capybara.current_session.visit(full_path)
        new
      end
    end
    
    module ClassMethods
      
      def can_load_from_current_url?
        return true if paths.empty?
        
        Capybara.current_session.wait_until do
          url = current_url_without_params
        
          paths.any? do |path|
            application.path_recognizes_url?(path, url)
          end
        end
      end
      
    private
          
      def paths
        @paths ||= []
      end
      
      def path(path_method)
        raise ArgumentError, "path must be a symbol or string" if ! path_method.is_a?(Symbol) && ! path_method.is_a?(String)

        paths << path_method
        
        extend VisitMethod
      end
    end
  end
end

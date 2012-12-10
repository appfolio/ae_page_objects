module AePageObjects
  module ConstantResolver
    extend ActiveSupport::Concern
    
    module ClassMethods
      def const_name_for(from_mod, const_name)
        name_within_universe = ""
        if self != from_mod
          name_within_universe = from_mod.name.split("#{self.name}::")[1]
        end

        name_within_universe += "::#{const_name}"
      end
      
      def load_missing_constant(from_mod, const_name)
        path_for_constant = self.const_name_for(from_mod, const_name).underscore

        application = "#{self.name}::Application".constantize
        application.all_autoload_paths.each do |autoload_path|
          file_path = File.join(autoload_path, "#{path_for_constant}.rb").sub(/(\.rb)?$/, ".rb")
          
          if File.file?(file_path) && ! ActiveSupport::Dependencies.loaded.include?(File.expand_path(file_path))
            ActiveSupport::Dependencies.require_or_load file_path
            raise LoadError, "Expected #{file_path} to define #{qualified_name}" unless ActiveSupport::Dependencies.local_const_defined?(from_mod, const_name)
            return from_mod.const_get(const_name)
          end
        end
        
        nil
      end
    end
  end
end
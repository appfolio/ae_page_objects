module AePageObjects
  module ConstantResolver
    extend ActiveSupport::Concern

    included do
      class << self
        attr_accessor :page_objects_application
      end
    end

    module ClassMethods

      def const_name_for(from_mod, const_name)
        name_within_universe = ""
        if self != from_mod
          name_within_universe = from_mod.name.split("#{self.name}::")[1]
        end

        name_within_universe += "::#{const_name}"
      end
      
      def load_missing_page_objects_constant(from_mod, const_name)
        path_for_constant = self.const_name_for(from_mod, const_name).underscore

        file_path = File.join(page_objects_application.instance.root_path, "#{path_for_constant}.rb").sub(/(\.rb)?$/, ".rb")

        if File.file?(file_path) && ! ActiveSupport::Dependencies.loaded.include?(File.expand_path(file_path))
          ActiveSupport::Dependencies.require_or_load file_path

          unless ActiveSupport::Dependencies.local_const_defined?(from_mod, const_name)
            qualified_name = ActiveSupport::Dependencies.qualified_name_for(from_mod, const_name)
            raise LoadError, "Expected #{file_path} to define #{qualified_name}"
          end

          from_mod.const_get(const_name)
        else
          nil
        end
      end
    end
  end
end
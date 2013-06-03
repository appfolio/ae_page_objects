module AePageObjects
  module DependenciesHook
    
    def self.containing_page_object_universe(from_mod)
      until from_mod == Object
        if from_mod < AePageObjects::ConstantResolver
          return from_mod
        end
        
        from_mod = from_mod.parent
      end
      
      nil
    end

    def load_missing_constant(from_mod, const_name)
      page_objects = DependenciesHook.containing_page_object_universe(from_mod)
      page_objects && page_objects.load_missing_page_objects_constant(from_mod, const_name) || super
    end
  end
end
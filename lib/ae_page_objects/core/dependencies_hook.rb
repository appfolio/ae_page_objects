module AePageObjects
  module DependenciesHook
    def load_missing_constant(from_mod, const_name)
      Application.from(from_mod).try(:resolve_constant, from_mod, const_name) || super
    end
  end
end
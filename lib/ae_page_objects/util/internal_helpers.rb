module AePageObjects
  module InternalHelpers
    def ensure_class_for_param!(param_name, klass, ancestor_class)
      if klass && ! (klass < ancestor_class)
        raise "#{param_name} <#{klass}> must extend #{ancestor_class}, ->#{klass.ancestors.inspect}"
      end
    end

    def self.deprecation_warning(message)
      warn "[DEPRECATION WARNING] for AePageObjects: #{message}. From: #{caller[1]}"
    end
  end
end
module AePageObjects
  class ConstantResolver
    def initialize(application, from_mod, const_name)
      @application = application
      @from_mod    = from_mod
      @const_name  = const_name

      @path_for_constant = path_for_constant
    end

    def load_constant_from_path(path)
      file_path = File.join(path, "#{@path_for_constant}.rb").sub(/(\.rb)?$/, ".rb")

      if File.file?(file_path) && ! ActiveSupport::Dependencies.loaded.include?(File.expand_path(file_path))
        ActiveSupport::Dependencies.require_or_load file_path

        unless ActiveSupport::Dependencies.local_const_defined?(@from_mod, @const_name)
          qualified_name = ActiveSupport::Dependencies.qualified_name_for(@from_mod, @const_name)
          raise LoadError, "Expected #{@file_path} to define #{qualified_name}"
        end

        @from_mod.const_get(@const_name)
      end
    end

  private

    def path_for_constant
      name_within_universe = ""
      if @application.universe != @from_mod
        name_within_universe = @from_mod.name.split("#{@application.universe.name}::")[1]
      end

      name_within_universe += "::#{@const_name}"
      name_within_universe.underscore
    end
  end
end
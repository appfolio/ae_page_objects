# lifted from activesupport

class Module

  # Returns the name of the module containing this one.
  #
  #   M::N.parent_name # => "M"
  def parent_name
    unless defined? @parent_name
      @parent_name = name =~ /::[^:]+\Z/ ? $`.freeze : nil
    end
    @parent_name
  end

  # Returns the module which contains this one according to its name.
  #
  #   module M
  #     module N
  #     end
  #   end
  #   X = M::N
  #
  #   M::N.parent # => M
  #   X.parent    # => M
  #
  # The parent of top-level and anonymous modules is Object.
  #
  #   M.parent          # => Object
  #   Module.new.parent # => Object
  #
  def parent
    parent_name ? AePageObjects::Inflector.constantize(parent_name) : Object
  end
end

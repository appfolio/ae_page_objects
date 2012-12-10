module AePageObjects
  module AttributeMethods
    module NestedNode
      extend ActiveSupport::Concern
      include Node
    
      module ClassMethods
        
        def node(name, options = {}, &block)
          raise ArgumentError, ":as option and block not supported together" if options[:as].present? && block_given?
          
          if block_given?
            klass = ::AePageObjects::HasOne.new_subclass(&block)
            
            options = options.dup
            options[:as] = klass
          end
          
          super(name, options)
        end
      end
    end
  end
end
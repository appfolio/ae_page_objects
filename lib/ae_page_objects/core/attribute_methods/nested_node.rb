module AePageObjects
  module AttributeMethods
    module NestedNode
      extend ActiveSupport::Concern
      include Node
    
      module ClassMethods
        
        def element(name, options = {}, &block)
          raise ArgumentError, ":is option and block not supported together" if options[:is].present? && block_given?
          
          if block_given?
            klass = ::AePageObjects::HasOne.new_subclass(&block)
            
            options = options.dup
            options[:is] = klass
          end
          
          super(name, options)
        end
      end
    end
  end
end
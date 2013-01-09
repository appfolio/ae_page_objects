module AePageObjects
  module Dsl
    module Element
      extend ActiveSupport::Concern
    
      module ClassMethods
        
        def inherited(subclass)
          subclass.class_eval do
            class << self
              def element_attributes
                @element_attributes ||= {}
              end
            end
          end
        end
        
        def element(name, options = {}, &block)
          options = options.dup 
          klass   = field_klass(options, &block)
          
          self.element_attributes[name.to_sym] = klass
        
          define_method name do |&block|
            ElementProxy.new(klass, self, name, options, &block)
          end
          
          klass
        end
      
      private
      
        def field_klass(options, &block)
          klass = options.delete(:is) || ::AePageObjects::Element
          
          if block_given?
            klass.new_subclass(&block)
          else
            klass
          end
        end
      end
    end
  end
end

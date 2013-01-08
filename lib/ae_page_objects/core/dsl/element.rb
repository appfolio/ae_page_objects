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
          raise ArgumentError, ":is option and block not supported together" if options[:is].present? && block_given?
          
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
          if block_given?
            ::AePageObjects::Element.new_subclass(&block)
          else
            options.delete(:is) || ::AePageObjects::Element
          end
        end
      end
    end
  end
end

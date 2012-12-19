module AePageObjects
  module AttributeMethods
    module Node
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
        
        def element(name, options = {})
          options = options.dup
          klass   = field_klass(options)
          
          self.element_attributes[name.to_sym] = klass
        
          define_method name do |&block|
            ElementProxy.new(klass, self, name, options, &block)
          end
          
          klass
        end
      
      private
      
        def field_klass(options)
          field_type = options.delete(:as)
        
          if field_type.is_a? Class
            field_type
          else
            ::AePageObjects::Element
          end
        end
      end
    end
  end
end

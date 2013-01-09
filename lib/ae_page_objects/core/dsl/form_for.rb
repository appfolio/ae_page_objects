module AePageObjects
  module Dsl
    module FormFor
      extend ActiveSupport::Concern
      include Dsl::Element
    
      module ClassMethods
    
        def form_for(form_name, options = {}, &block)
          options ||= {}
        
          raise ArgumentError, ":is option not supported" if options[:is]
          raise ArgumentError, "Block required." unless block.present?
        
          klass = ::AePageObjects::Form.new_subclass(&block)
        
          options      = options.dup
          options[:is] = klass
      
          element(form_name, options)
        
          klass.element_attributes.each do |element_name, element_klazz|
            delegate element_name, :to => form_name
            self.element_attributes[element_name] = element_klazz
          end
        end
      end
    end
  end
end
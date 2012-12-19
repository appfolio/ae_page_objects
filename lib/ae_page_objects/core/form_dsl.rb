module AePageObjects
  module FormDsl
    extend ActiveSupport::Concern
    include AttributeMethods::Node
    include AttributeMethods::NestedNode
    include AttributeMethods::Nodes
    
    module ClassMethods
    
      def form_for(form_name, options = {}, &block)
        options ||= {}
        
        raise ArgumentError, ":is option not supported" if options[:is]
        raise ArgumentError, "Block required." unless block.present?
        
        klass = ::AePageObjects::Form.new_subclass(&block)
        
        options      = options.dup
        options[:is] = klass
      
        element(form_name, options)
        
        klass.element_attributes.each do |node_name, node_klazz|
          delegate node_name, :to => form_name
          self.element_attributes[node_name] = node_klazz
        end
      end
    end
  end
end

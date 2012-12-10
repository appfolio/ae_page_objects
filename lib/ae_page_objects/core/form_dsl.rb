module AePageObjects
  module FormDsl
    extend ActiveSupport::Concern
    include AttributeMethods::Node
    include AttributeMethods::NestedNode
    include AttributeMethods::Nodes
    
    included do
      class << self
        alias has_one  node
        alias field    node
        alias has_many nodes
      end
    end

    module ClassMethods
    
      def form_for(form_name, options = {}, &block)
        options ||= {}
        
        raise ArgumentError, ":as option not supported" if options[:as]
        raise ArgumentError, "Block required." unless block.present?
        
        klass = ::AePageObjects::Form.new_subclass(&block)
        
        options      = options.dup
        options[:as] = klass
      
        node(form_name, options)
        
        klass.node_attributes.each do |node_name, node_klazz|
          delegate node_name, :to => form_name
          self.node_attributes[node_name] = node_klazz
        end
      end
    end
  end
end
